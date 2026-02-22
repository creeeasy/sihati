import model from '../config/gemini';

class AIService {
  // Send a general query to Gemini
  async sendQuery(query: string): Promise<string> {
    try {
      const result = await model.generateContent(query);
      return result.response.text();
    } catch (error) {
      console.error('AIService.sendQuery error:', error);
      return "Désolé, je n'arrive pas à traiter votre demande pour le moment. Veuillez réessayer.";
    }
  }

  // Get OTC medication suggestions based on symptoms
  async getMedicationSuggestions(symptoms: string): Promise<string[]> {
    try {
      const prompt = `Un patient décrit ces symptômes : "${symptoms}".
Suggère jusqu'à 5 médicaments sans ordonnance disponibles en Algérie.
Réponds UNIQUEMENT avec une liste de noms de médicaments séparés par des virgules, sans explication. Exemple: Doliprane, Aspégic, Spasfon`;

      const result = await model.generateContent(prompt);
      const text = result.response.text();

      return text
        .split(',')
        .map((m) => m.trim())
        .filter((m) => m.length > 0)
        .slice(0, 5);
    } catch (error) {
      console.error('AIService.getMedicationSuggestions error:', error);
      return [];
    }
  }

  // Check if two medications can be taken together
  async checkDrugInteraction(med1: string, med2: string): Promise<string> {
    try {
      const prompt = `Est-ce que "${med1}" et "${med2}" peuvent être pris ensemble sans danger ?
Commence ta réponse par OUI ou NON, puis explique brièvement en 2-3 phrases.`;

      const result = await model.generateContent(prompt);
      return result.response.text();
    } catch (error) {
      console.error('AIService.checkDrugInteraction error:', error);
      return "Impossible de vérifier l'interaction pour le moment. Consultez un pharmacien.";
    }
  }

  // Get detailed info about a medication
  async getMedicationInfo(medicationName: string): Promise<string> {
    try {
      const prompt = `Donne-moi des informations sur le médicament "${medicationName}" disponible en Algérie :
- Utilisation principale
- Dosage habituel
- Précautions importantes
- Effets secondaires courants
Réponds de manière concise en français.`;

      const result = await model.generateContent(prompt);
      return result.response.text();
    } catch (error) {
      console.error('AIService.getMedicationInfo error:', error);
      return 'Impossible de récupérer les informations sur ce médicament pour le moment.';
    }
  }

  // Suggest which medical specialty to consult based on symptoms
  async suggestSpecialty(symptoms: string): Promise<string> {
    try {
      const prompt = `Un patient a ces symptômes : "${symptoms}".
Quelle spécialité médicale devrait-il consulter ?
Réponds avec UNE SEULE spécialité et une brève raison (1-2 phrases maximum).`;

      const result = await model.generateContent(prompt);
      return result.response.text();
    } catch (error) {
      console.error('AIService.suggestSpecialty error:', error);
      return 'Impossible de suggérer une spécialité pour le moment. Consultez un médecin généraliste.';
    }
  }
}

export default new AIService();