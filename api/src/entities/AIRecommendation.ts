import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn
} from "typeorm";
import type { User } from "./User";
import type { Game } from "./Game";

@Entity("AIRecommandations")
export class AIRecommendation {
  @PrimaryColumn()
  id_user!: number;

  @PrimaryColumn()
  id_game!: number;

  @ManyToOne("User", (user: User) => user.aiRecommendations, { onDelete: "CASCADE" })
  @JoinColumn({ name: "id_user" })
  user!: User;

  @ManyToOne("Game", (game: Game) => game.aiRecommendations)
  @JoinColumn({ name: "id_game" })
  game!: Game;

  @Column("float")
  score!: number;

  @CreateDateColumn()
  created_at!: Date;
}
