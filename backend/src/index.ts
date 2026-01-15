import express from "express";
import cors from "cors"; 
import authRouter from "./routes/auth";

const app = express();
const PORT = 8000;

app.use(express.json()); // Permite recibir JSON
app.use(cors()); // Permite conexiones externas

// Conectamos la ruta de autenticación
app.use("/auth", authRouter); 

// Arrancamos el servidor
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server started at port ${PORT} 🚀`);
});