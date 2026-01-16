import express from "express";
import cors from "cors"; 
import authRouter from "./routes/auth";
import tasksRouter from "./routes/tasks";

const app = express();
const PORT = 8000;

app.use(express.json()); // Permite recibir JSON
app.use(cors()); // Permite conexiones externas

// 👇 AÑADE ESTO (EL CHIVATO) 👇
app.use((req, res, next) => {
  console.log(`🔔 PETICIÓN ENTRANTE: ${req.method} ${req.url}`);
  console.log(`   Headers:`, req.headers['x-auth-token'] ? "Token presente" : "Sin token");
  next(); // Importante: deja pasar a la siguiente fase
});
// 👆 -------------------------- 👆

// Conectamos la ruta de autenticación
app.use("/auth", authRouter); 
app.use("/tasks",tasksRouter);

// Arrancamos el servidor
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server started at port ${PORT} 🚀`);
});