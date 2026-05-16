// src/controllers/waitingQueueController.ts
import { Request, Response, NextFunction } from 'express';
import waitingQueueService from '../services/waitingQueueService';

const getId = (param: string | string[] | undefined): string => {
  if (typeof param === 'string') return param;
  if (Array.isArray(param)) return param[0];
  return '';
};

// GET /api/waiting-queue/doctor/:doctorId
// Can accept either doctor ID (dddddddd-dddd-dddd-dddd-dddddddddddd) 
// OR user ID (22222222-2222-2222-2222-222222222222)
export const getQueue = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctorId = getId(req.params.doctorId);
    console.log('Received identifier from request:', doctorId);
    
    const queue = await waitingQueueService.getQueue(doctorId);
    console.log(`Found ${queue.length} queue entries`);
    
    return res.json({ success: true, data: queue });
  } catch (error) {
    return next(error);
  }
};

// POST /api/waiting-queue
// Body: { doctorIdOrUserId: string, patientId: string, ... }
export const addPatient = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { doctorId:doctorIdOrUserId, patientId, appointmentId, priority, notes } = req.body;
    console.log(req.body)
    // Validate required fields
    if (!doctorIdOrUserId || !patientId) {
      return res.status(400).json({ 
        success: false, 
        message: 'doctorIdOrUserId and patientId are required' 
      });
    }
    
    const entry = await waitingQueueService.addPatient({ 
      doctorIdOrUserId, 
      patientId, 
      appointmentId, 
      priority, 
      notes 
    });
    
    return res.status(201).json({ success: true, data: entry });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/waiting-queue/doctor/:doctorId/next
export const callNext = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctorId = getId(req.params.id);
    if (!doctorId) {
      return res.status(400).json({ success: false, message: 'doctorId is required' });
    }
    
    const entry = await waitingQueueService.callNext(doctorId);
    if (!entry) {
      return res.status(404).json({ success: false, message: 'No patients waiting' });
    }
    
    return res.json({ success: true, data: entry });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/waiting-queue/:id/complete
export const completeConsultation = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    if (!id) {
      return res.status(400).json({ success: false, message: 'Queue entry ID is required' });
    }
    
    const entry = await waitingQueueService.completeConsultation(id);
    return res.json({ success: true, data: entry });
  } catch (error) {
    return next(error);
  }
};

// PUT /api/waiting-queue/:id/priority
export const setPriority = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const { priority } = req.body;
    
    if (!id || priority === undefined) {
      return res.status(400).json({ success: false, message: 'Queue entry ID and priority are required' });
    }
    
    const entry = await waitingQueueService.setPriority(id, priority);
    return res.json({ success: true, data: entry });
  } catch (error) {
    return next(error);
  }
};

// DELETE /api/waiting-queue/:id
export const removePatient = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = getId(req.params.id);
    const { reason } = req.body;
    
    if (!id) {
      return res.status(400).json({ success: false, message: 'Queue entry ID is required' });
    }
    
    const entry = await waitingQueueService.removePatient(id, reason);
    return res.json({ success: true, data: entry });
  } catch (error) {
    return next(error);
  }
};

// Optional: GET /api/waiting-queue/doctor/:doctorId/info - Get doctor info
export const getDoctorInfo = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const doctorId = getId(req.params.doctorId);
    const doctor = await waitingQueueService.getDoctorInfo(doctorId);
    
    if (!doctor) {
      return res.status(404).json({ success: false, message: 'Doctor not found' });
    }
    
    return res.json({ success: true, data: doctor });
  } catch (error) {
    return next(error);
  }
};