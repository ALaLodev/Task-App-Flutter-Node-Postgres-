import { Router, Response } from "express";
import { authMiddleware, AuthRequest } from "../middleware/auth";
import { PrismaClient } from "@prisma/client";
import { error } from "node:console";

const tasksRouter = Router();
const prisma = new PrismaClient();

tasksRouter.post("/", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const uid = req.user;
    
    // 👇 1. AHORA RECIBIMOS TAMBIÉN EL 'id'
    const { id, title, hexColor, description, dueDate } = req.body;

    // Log para depurar (mira esto en la terminal si falla)
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

tasksRouter.post("/sync", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { id, isCompleted } = req.body; // Recibimos el ID y el nuevo estado

    // Validamos que nos manden el ID
    if (!id) {
      res.status(400).json({ error: "Task ID is required" });
      return;
    }

    console.log(`🔄 Actualizando tarea ${id} a estado: ${isCompleted}`);

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

export default tasksRouter;