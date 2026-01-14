import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn
} from "typeorm";
import type { User } from "./User";
import type { Game } from "./Game";

@Entity("Reviews")
export class Review {
  @PrimaryGeneratedColumn()
  id_review!: number;

  @Column()
  id_game!: number;

  @Column()
  id_user!: number;

  @ManyToOne("Game", (game: Game) => game.reviews)
  @JoinColumn({ name: "id_game" })
  game!: Game;

  @ManyToOne("User", (user: User) => user.reviews)
  @JoinColumn({ name: "id_user" })
  user!: User;

  @Column("text", { nullable: true })
  text!: string;
}
