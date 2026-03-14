import {
  Entity,
  PrimaryColumn,
  Column,
  ManyToOne,
  JoinColumn
} from "typeorm";
import type { User } from "./User";
import type { Game } from "./Game";

@Entity("GamesUsers")
export class GameUser {
  @PrimaryColumn()
  id_user!: number;

  @PrimaryColumn()
  id_game!: number;

  @ManyToOne("User", (user: User) => user.library, { onDelete: "CASCADE" })
  @JoinColumn({ name: "id_user" })
  user!: User;

  @ManyToOne("Game", (game: Game) => game.owners)
  @JoinColumn({ name: "id_game" })
  game!: Game;

  @Column("float", { default: 0 })
  nb_hours!: number;
}
