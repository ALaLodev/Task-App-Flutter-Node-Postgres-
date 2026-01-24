import { Router, Response } from "express";
import { authMiddleware, AuthRequest } from "../middleware/auth";
import { PrismaClient } from "@prisma/client";
import { error } from "node:console";

const tasksRouter = Router();
const prisma = new PrismaClient();

tasksRouter.post("/", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user;
    
    const { id, title, hexColor, description, dueDate } = req.body;

    // Log para depurar 
    console.log("📥 Recibiendo tarea:", { id, title, dueDate });

    const newTask = await prisma.task.create({
      data: {
        id: id, // 👈 2. IMPORTANTE: Usamos el ID que viene de Flutter
        title,
        description,
        hexColor,
        uid: uid!,
        // Convertimos el string ISO a objeto Date
        dueDate: dueDate ? new Date(dueDate) : new Date(),
        // Prisma se encarga de createdAt y updatedAt automáticamente
      },
    });

    res.status(201).json(newTask);
    
  } catch (e) {
    // 👇 ESTO ES LO QUE NECESITAS VER SI FALLA
    console.log("❌ ERROR FATAL AL CREAR TAREA:", e); 
    res.status(500).json({ error: (e as Error).message });
  }
});

tasksRouter.get("/", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const userId = req.user;

    const tasks = await prisma.task.findMany({
      where: {
        uid: userId, 
      },
    });

    console.log(`✅ Tareas encontradas: ${tasks.length}`); 
    res.json(tasks);
  } catch (e) {
    console.log("❌ ERROR EN BASE DE DATOS:", e); // Log Error
    res.status(500).json({ error: (e as Error).message });
  }
});

tasksRouter.post("/sync", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id, isCompleted } = req.body; // Recibimos el ID y el nuevo estado

    // Validamos que nos manden el ID
    if (!id) {
      res.status(400).json({ error: "Task ID is required" });
      return;
    }

    // Actualizamos en la base de datos
    const updatedTask = await prisma.task.update({
      where: {
        id: id,
      },
      data: {
        isCompleted: isCompleted,
      },
    });

    res.json(updatedTask);
  } catch (e) {
    console.log("❌ Error al actualizar tarea:", e);
    res.status(500).json({ error: "No se pudo actualizar la tarea" });
  }
});

tasksRouter.delete("/:taskId", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { taskId } = req.params as {taskId: string}; // Cogemos el ID de la URL

    await prisma.task.delete({
      where: {
        id: taskId,
      },
    });

    res.json({ message: "Task deleted successfully" });
  } catch (e) {
    res.status(500).json({ error: "Error deleting task" });
  }
});

tasksRouter.put("/:taskId", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { taskId } = req.params as {taskId: string};
    const { title, description, hexColor, dueDate } = req.body;

    const updatedTask = await prisma.task.update({
      where: { id: taskId },
      data: {
        title,
        description,
        hexColor,
        // Si nos mandan fecha nueva la convertimos, si no, no la tocamos
        dueDate: dueDate ? new Date(dueDate) : undefined, 
      },
    });

    res.json(updatedTask);
  } catch (e) {
    res.status(500).json({ error: "Error updating task" });
  }
});

export default tasksRouter;