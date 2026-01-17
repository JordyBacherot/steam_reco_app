import { Hono } from "hono";
import { z } from "zod";
import { zValidator } from "@hono/zod-validator";
import SignUp from "../handlers/auth/SignUp";
import GetMe from "../handlers/auth/GetMe";
import SignIn from "../handlers/auth/SignIn";
import RefreshToken from "../handlers/auth/RefreshToken";
import ChangePassword from "../handlers/auth/ChangePassword";
import { authMiddleware } from "../middlewares/auth";

const router = new Hono();

const signInSchema = z.object({
  email: z.string().email(),
  password: z.string().min(4)
});

const signUpSchema = z.object({
  email: z.string().email(),
  password: z.string().min(4),
  username: z.string().min(1)
});

// Schéma pour le Refresh Token
const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1)
});

// Schéma pour le changement de mot de passe
const changePasswordSchema = z.object({
  oldPassword: z.string().min(1),
  newPassword: z.string().min(4)
});

// Création de compte (nécessite username)
router.post("/signup", zValidator("json", signUpSchema), SignUp);

// Connexion (seulement email/password)
router.post("/signin", zValidator("json", signInSchema), SignIn);

// Rafraîchissement du token (Public, car on a juste besoin du refresh token)
router.post("/refresh", zValidator("json", refreshTokenSchema), RefreshToken);

// Changement de mot de passe (Protégé)
router.post("/password/change", authMiddleware, zValidator("json", changePasswordSchema), ChangePassword);

// Profil (protégé par le middleware)
router.get("/me", authMiddleware, GetMe);

export default router;
