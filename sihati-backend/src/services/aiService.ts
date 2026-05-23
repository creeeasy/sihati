// src/services/aiService.ts
import model from '../config/gemini';
import { Medication, Pharmacy } from '../models';
import { Op } from 'sequelize';
import {
  ChatHistoryItem,
  ChatResponse,
  InteractionResponse,
  MedicationInfoResponse,
  SpecialtyResponse,
  AIMedicationResult,
  PharmacyStock,
  UrgencyLevel,
} from '../types';

function safeParseJSON<T>(text: string, fallback: T): T {
  try {
    const cleaned = text
      .replace(/^```json\s*/i, '')
      .replace(/^```\s*/i, '')
      .replace(/\s*```$/i, '')
      .trim();
    return JSON.parse(cleaned) as T;
  } catch {
    return fallback;
  }
}

function haversine(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371;
  const dLat = ((lat2 - lat1) * Math.PI) / 180;
  const dLng = ((lng2 - lng1) * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos((lat1 * Math.PI) / 180) *
      Math.cos((lat2 * Math.PI) / 180) *
      Math.sin(dLng / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

const CHAT_PROMPT = (message: string) => `
Tu es un assistant santé algérien. Un patient dit: "${message}"

Réponds UNIQUEMENT avec un objet JSON valide (sans markdown, sans backticks):
{
  "reply": "Ta réponse en français (3-5 phrases max, bienveillante et claire)",
  "urgency": "low|medium|high|emergency",
  "isSymptomRelated": true|false,
  "suggestedSpecialty": "Nom exact de la spécialité ou null",
  "medicationNames": ["nom1", "nom2"]
}

Règles urgency:
- emergency: douleur thoracique, difficultés respiratoires, perte de conscience, AVC, hémorragie
- high: fièvre >39°C, douleur intense, symptômes qui s'aggravent rapidement
- medium: symptômes modérés depuis plus de 48h
- low: symptômes légers, question d'information générale

Règles medicationNames:
- Seulement si isSymptomRelated = true
- Maximum 4 médicaments OTC disponibles en Algérie (ex: Doliprane, Spasfon, Aspégic)
- [] si aucun applicable ou si urgency = emergency
`.trim();

const INTERACTION_PROMPT = (med1: string, med2: string) => `
Vérifie l'interaction médicamenteuse entre "${med1}" et "${med2}".
Réponds UNIQUEMENT avec un JSON valide (sans markdown):
{
  "safe": true|false,
  "severity": "none|mild|moderate|severe",
  "reply": "Explication courte en français (2-3 phrases)"
}
`.trim();

const MED_INFO_PROMPT = (name: string, dbContext: string) => `
Tu es un pharmacien expert en Algérie. Donne des informations détaillées sur le médicament "${name}".
${dbContext ? `Données de notre base: ${dbContext}` : ''}
Réponds UNIQUEMENT avec un JSON valide (sans markdown), tous les textes en français:
{
  "reply": "Résumé court et utile pour le patient (2-3 phrases)",
  "usage": "Pour quelles maladies ou symptômes ce médicament est utilisé",
  "contraindications": "Qui ne doit pas prendre ce médicament",
  "dosage": "Dosage adulte standard, fréquence et durée",
  "sideEffects": "Effets secondaires courants et graves",
  "pregnancy": "Sécurité pendant la grossesse et l'allaitement",
  "interactions": "Médicaments à éviter avec celui-ci",
  "warnings": "Précautions importantes, conservation, ordonnance requise oui/non"
}
`.trim();

const SPECIALTY_PROMPT = (symptoms: string) => `
Un patient algérien décrit: "${symptoms}"
Quelle spécialité médicale devrait-il consulter?
Réponds UNIQUEMENT avec un JSON valide (sans markdown):
{
  "specialty": "Nom exact de la spécialité",
  "reason": "Raison courte en français (1 phrase)",
  "urgency": "low|medium|high|emergency"
}
`.trim();

class AIService {

  async sendQuery(
    message: string,
    history: ChatHistoryItem[] = [],
    location?: { lat: number; lng: number }
  ): Promise<ChatResponse> {
    try {
      let trimmedHistory = history.slice(-10);

      while (trimmedHistory.length > 0 && trimmedHistory[0].role !== 'user') {
        trimmedHistory = trimmedHistory.slice(1);
      }

      const chat = model.startChat({ history: trimmedHistory });
      const result = await chat.sendMessage(CHAT_PROMPT(message));
      const raw = result.response.text();

      const parsed = safeParseJSON<any>(raw, null);

      if (!parsed) {
        return {
          reply: raw,
          urgency: 'low',
          isSymptomRelated: false,
          suggestedSpecialty: null,
          medicationSuggestions: [],
        };
      }

      let medicationSuggestions: AIMedicationResult[] = [];
      if (
        parsed.isSymptomRelated &&
        Array.isArray(parsed.medicationNames) &&
        parsed.medicationNames.length > 0
      ) {
        medicationSuggestions = await this._lookupMedications(
          parsed.medicationNames,
          location
        );
      }

      return {
        reply: parsed.reply ?? raw,
        urgency: (parsed.urgency as UrgencyLevel) ?? 'low',
        isSymptomRelated: parsed.isSymptomRelated ?? false,
        suggestedSpecialty: parsed.suggestedSpecialty ?? null,
        medicationSuggestions,
      };
    } catch (error: any) {
      console.error('AIService.sendQuery error:', error);
      const is429 = error?.status === 429 || error?.message?.includes('429');
      return {
        reply: is429
          ? "Le service IA est temporairement surchargé. Veuillez réessayer dans quelques instants."
          : "Désolé, je n'arrive pas à traiter votre demande. Veuillez réessayer.",
        urgency: 'low',
        isSymptomRelated: false,
        suggestedSpecialty: null,
        medicationSuggestions: [],
      };
    }
  }

  private async _lookupMedications(
    names: string[],
    location?: { lat: number; lng: number }
  ): Promise<AIMedicationResult[]> {
    try {
      const nameConditions = names.map((n) => ({
        [Op.or]: [
          { name: { [Op.iLike]: `%${n}%` } },
          { genericName: { [Op.iLike]: `%${n}%` } },
        ],
      }));

      const medications = await Medication.findAll({
        where: { [Op.or]: nameConditions },
        include: [
          {
            model: Pharmacy,
            as: 'pharmacies',
            through: { attributes: ['inStock', 'price'] },
          },
        ],
        limit: 4,
      });

      const results: AIMedicationResult[] = medications.map((med) => {
        const pharmacyRows = ((med as any).pharmacies ?? []).map((p: any): PharmacyStock => {
          const junction = p.PharmacyMedication ?? p.pharmacy_medications;
          const dist = location
            ? Math.round(haversine(location.lat, location.lng, Number(p.latitude), Number(p.longitude)) * 10) / 10
            : undefined;

          return {
            pharmacyId: p.id,
            pharmacyName: p.pharmacyName,
            wilaya: p.wilaya,
            phone: p.phone,
            isOnDutyTonight: p.isOnDutyTonight,
            inStock: junction?.inStock ?? false,
            price: junction?.price ? Number(junction.price) : null,
            distance: dist,
          };
        });

        pharmacyRows.sort((a: PharmacyStock, b: PharmacyStock) => {
          if (a.distance !== undefined && b.distance !== undefined) {
            return a.distance - b.distance;
          }
          return Number(b.isOnDutyTonight) - Number(a.isOnDutyTonight);
        });

        return {
          name: med.name,
          genericName: med.genericName ?? null,
          category: med.category ?? null,
          requiresPrescription: med.requiresPrescription,
          basePrice: null, // Medication model has no price field
          foundInDb: true,
          availableInPharmacies: pharmacyRows.slice(0, 5),
        };
      });

      const foundNames = results.map((r) => r.name.toLowerCase());
      for (const name of names) {
        const alreadyFound = foundNames.some((fn) => fn.includes(name.toLowerCase()));
        if (!alreadyFound) {
          results.push({
            name,
            genericName: null,
            category: null,
            requiresPrescription: false,
            basePrice: null,
            foundInDb: false,
            availableInPharmacies: [],
          });
        }
      }

      return results;
    } catch (error) {
      console.error('AIService._lookupMedications error:', error);
      return [];
    }
  }

  async checkDrugInteraction(med1: string, med2: string): Promise<InteractionResponse> {
    try {
      const result = await model.generateContent(INTERACTION_PROMPT(med1, med2));
      const parsed = safeParseJSON<any>(result.response.text(), null);
      if (!parsed) throw new Error('parse failed');

      return {
        safe: parsed.safe ?? true,
        severity: parsed.severity ?? 'unknown',
        reply: parsed.reply,
      };
    } catch (error) {
      console.error('AIService.checkDrugInteraction error:', error);
      return {
        safe: true,
        severity: 'unknown',
        reply: "Impossible de vérifier l'interaction. Consultez un pharmacien.",
      };
    }
  }

  async getMedicationInfo(medicationName: string): Promise<MedicationInfoResponse> {
    try {
      const dbMed = await Medication.findOne({
        where: {
          [Op.or]: [
            { name: { [Op.iLike]: `%${medicationName}%` } },
            { genericName: { [Op.iLike]: `%${medicationName}%` } },
          ],
        },
      });

      const dbContext = dbMed
        ? `nom=${dbMed.name}, générique=${dbMed.genericName ?? 'N/A'}, forme=${dbMed.form ?? 'N/A'}, dosage=${dbMed.dosage ?? 'N/A'}, catégorie=${dbMed.category ?? 'N/A'}`
        : '';

      const result = await model.generateContent(MED_INFO_PROMPT(medicationName, dbContext));
      const parsed = safeParseJSON<any>(result.response.text(), null);

      return {
        reply:             parsed?.reply ?? result.response.text(),
        usage:             parsed?.usage ?? '',
        contraindications: parsed?.contraindications ?? '',
        dosage:            parsed?.dosage ?? '',
        sideEffects:       parsed?.sideEffects ?? '',
        pregnancy:         parsed?.pregnancy ?? '',
        interactions:      parsed?.interactions ?? '',
        warnings:          parsed?.warnings ?? '',
        foundInDb:         !!dbMed,
        dbData: dbMed
          ? {
              name:                 dbMed.name,
              genericName:          dbMed.genericName ?? null,
              price:                null, // No price column on Medication
              requiresPrescription: dbMed.requiresPrescription,
              category:             dbMed.category ?? null,
              dosageForm:           dbMed.form ?? null,
              strength:             dbMed.dosage ?? null,
            }
          : undefined,
      };
    } catch (error) {
      console.error('AIService.getMedicationInfo error:', error);
      return {
        reply:             'Impossible de récupérer les informations.',
        usage:             '',
        contraindications: '',
        dosage:            '',
        sideEffects:       '',
        pregnancy:         '',
        interactions:      '',
        warnings:          '',
        foundInDb:         false,
      };
    }
  }

  async askMedicationQuestion(medicationName: string, question: string): Promise<{ answer: string }> {
    try {
      const prompt = `
Tu es un pharmacien expert en Algérie. Un patient te pose une question sur le médicament "${medicationName}".

Question: "${question}"

Réponds en français, de façon claire et concise (2-4 phrases max).
Ne donne pas de diagnostic médical. Si la question dépasse tes compétences, recommande de consulter un médecin.
Réponds UNIQUEMENT avec un JSON valide (sans markdown):
{ "answer": "Ta réponse ici" }
`.trim();

      const result = await model.generateContent(prompt);
      const parsed = safeParseJSON<any>(result.response.text(), null);

      return {
        answer: parsed?.answer ?? result.response.text(),
      };
    } catch (error) {
      console.error('AIService.askMedicationQuestion error:', error);
      return {
        answer: 'Désolé, impossible de répondre à cette question. Consultez un pharmacien.',
      };
    }
  }

  async suggestSpecialty(symptoms: string): Promise<SpecialtyResponse> {
    try {
      const result = await model.generateContent(SPECIALTY_PROMPT(symptoms));
      const parsed = safeParseJSON<any>(result.response.text(), null);
      if (!parsed) throw new Error('parse failed');

      return {
        specialty: parsed.specialty ?? 'Médecine Générale',
        reason: parsed.reason ?? '',
        urgency: (parsed.urgency as UrgencyLevel) ?? 'low',
      };
    } catch (error) {
      console.error('AIService.suggestSpecialty error:', error);
      return {
        specialty: 'Médecine Générale',
        reason: 'Consultez un médecin généraliste.',
        urgency: 'low',
      };
    }
  }
}

export default new AIService();