import { Request, Response, NextFunction } from "express";
import jwt, { JwtPayload } from "jsonwebtoken";

// Extendemos la interfaz de Request para poder guardar el id del usuario
export interface AuthRequest extends Request {
  user?: string;
  token?: string;
}

export const authMiddleware = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    // 1. Obtenemos el token de la cabecera 'x-auth-token'
    const token = req.header("x-auth-token");

    if (!token) {
       res.status(401).json({ msg: "No auth token, access denied!" });
       return;
    }

    // 2. Verificamos si el token es real y no ha caducado
    // "passwordKey" debe ser la misma clave que usaste al crear el token
    const verified = jwt.verify(token, "passwordKey");

    if (!verified) {
       res.status(401).json({ msg: "Token verification failed, authorization denied." });
       return;
    }

    // 3. Guardamos el ID del usuario y el token en la request para usarlo luego
    // (verified as JwtPayload).id asume que en el token guardaste un campo 'id'
    req.user = (verified as JwtPayload).id;
    req.token = token;

    // 4. Dejamos pasar a la siguiente función
    next();
    
  } catch (e) {
    res.status(500).json({ error: (e as Error).message });
  }
};