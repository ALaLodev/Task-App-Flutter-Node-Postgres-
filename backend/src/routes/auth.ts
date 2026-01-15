import { Router, Request, Response, NextFunction } from "express"; // Importamos tipos
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import prisma from "../db"; // Importamos la conexión
import { authMiddleware, AuthRequest } from "../middleware/auth";

const authRouter = Router();


authRouter.post("/signup", async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { name, email, password } = req.body;

    // 1. Validar si el usuario ya existe
    const existingUser = await prisma.user.findFirst({
      where: { email: email },
    });

    if (existingUser) {
      res.status(400).json({ msg: "User with this email already exists!" });
      return; 
    }

    // 2. Encriptar la contraseña (seguridad básica)
    const hashedPassword = await bcryptjs.hash(password, 8);

    // 3. Guardar en la Base de Datos (usando el cliente que generó la migración)
    const user = await prisma.user.create({
      data: {
        email: email,
        password: hashedPassword,
        name: name,
      },
    });

    // 4. Responder con éxito
    res.json(user);
    
  } catch (e) {
    res.status(500).json({ error: (e as Error).message });
  }
});

authRouter.post("/login", async(req: Request, res: Response, next: NextFunction): Promise<void> =>{
  try{
    const {email, password} = req.body;

    // 1. Buscar usuario
    const user = await prisma.user.findFirst({where: {email: email},});
    if (!user){
      res.status(400).json({msg: "User with this email does not exist!"});
      return;
    }
    // 2. Comparar contraseñas (La que envía el usuario VS la encriptada en DB)
    const isMatch = await bcryptjs.compare(password, user.password);
    if (!isMatch) {
      res.status(400).json({ msg: "Incorrect password." });
      return; 
    }
    // 3. Generar el Token (JWT)
    // "passwordKey" es la clave secreta para firmar el token. En producción esto va en .env
    const token = jwt.sign({ id: user.id }, "passwordKey");
    // 4. Devolver usuario y token
    // IMPORTANTE: Devolvemos el objeto user y añadimos el campo token
    res.json({ token, ...user });
  }catch(e){res.status(500).json({ error: (e as Error).message });}
});

// RUTA: Obtener datos del usuario actual
// Fíjate que ponemos 'authMiddleware' en medio
authRouter.get("/", authMiddleware, async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    // Buscamos al usuario usando el ID que el middleware extrajo del token
    const user = await prisma.user.findFirst({
      where: { id: req.user },
    });
    
    // Devolvemos el usuario y añadimos el token que nos enviaron
    res.json({ ...user, token: req.token });
    
  } catch (e) {
    res.status(500).json({ error: (e as Error).message });
  }
});

export default authRouter;