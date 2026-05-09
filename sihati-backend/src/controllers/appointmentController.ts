// src/controllers/appointmentController.ts
import { Request, Response, NextFunction } from 'express';
import appointmentService from '../services/appointmentService';

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// GET /api/appointments/doctor/:doctorId
export const getDoctorAppointments = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctorId = getId(req.params.doctorId);
    const { status } = req.query;
    const appointments = await appointmentService.getDoctorAppointments(doctorId, status as string);
    return res.json({ success: true, data: appointments });
  } catch (error) {
    return next(error);
  }
};

// GET /api/appointments/patient/:patientId
export const getPatientAppointments = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const patientId = getId(req.params.patientId);
    const { status } = req.query;
    
    const appointments = await appointmentService.getPatientAppointments(patientId, status as string);
    return res.json({ success: true, data: appointments });
  } catch (error) {
    return next(error);
  }
};

// POST /api/appointments
export const createAppointment = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const appointment = await appointmentService.createAppointment(req.body);
    return res.status(201).json({ success: true, data: appointment });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/appointments/:id/confirm
export const confirmAppointment = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const appointment = await appointmentService.confirmAppointment(id);
    return res.json({ success: true, data: appointment });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/appointments/:id/cancel
export const cancelAppointment = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const { reason } = req.body;
    const appointment = await appointmentService.cancelAppointment(id, reason);
    return res.json({ success: true, data: appointment });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/appointments/:id/complete
export const completeAppointment = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const appointment = await appointmentService.completeAppointment(id);
    return res.json({ success: true, data: appointment });
  } catch (error) {
    return next(error);
  }
};

// GET /api/appointments/:id
export const getAppointmentById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const appointment = await appointmentService.getAppointmentById(id);
    return res.json({ success: true, data: appointment });
  } catch (error) {
    return next(error);
  }
};