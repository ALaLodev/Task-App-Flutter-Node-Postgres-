import { Router, Response } from "express";
import { authMiddleware, AuthRequest } from "../middleware/auth";
import { PrismaClient } from "@prisma/client";

const tasksRouter = Router();
const prisma = new PrismaClient();

// RUTA: POST /tasks
// Crea una nueva tarea
tasksRouter.post("/", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    // 1. Obtenemos el ID del usuario gracias al middleware (req.user)
    const uid = req.user; 
    
    // 2. Obtenemos los datos que envía el móvil
    const { title, description, hexColor } = req.body;

    // 3. Guardamos en la base de datos
    const newTask = await prisma.task.create({
      data: {
        title,
        description,
        hexColor,
        uid: uid!, // El signo ! le dice a TS que confiamos en que uid existe
        dueDate: new Date()
      },
    });

    // 4. Devolvemos la tarea creada
    res.json(newTask);
    
  } catch (e) {
    res.status(500).json({ error: (e as Error).message });
  }
});

tasksRouter.get("/", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  console.log("👉 HE ENTRADO EN LA RUTA GET /TASKS"); // Log 1
  try {
    const userId = req.user;
    console.log("👤 Buscando tareas para el usuario:", userId); // Log 2

    const tasks = await prisma.task.findMany({
      where: {
        uid: userId, 
      },
    });

    console.log(`✅ Tareas encontradas: ${tasks.length}`); // Log 3
    res.json(tasks);
  } catch (e) {
    console.log("❌ ERROR EN BASE DE DATOS:", e); // Log Error
    res.status(500).json({ error: (e as Error).message });
  }
});
export default tasksRouter;