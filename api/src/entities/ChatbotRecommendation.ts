import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn
} from "typeorm";
import type { User } from "./User";

@Entity("ChatbotRecommandations")
export class ChatbotRecommendation {
  @PrimaryGeneratedColumn()
  id_chatbot_reco!: number;

  @Column()
  id_user!: number;

  @ManyToOne("User", (user: User) => user.chatbotRecommendations, { onDelete: "CASCADE" })
  @JoinColumn({ name: "id_user" })
  user!: User;

  @Column("uuid", { nullable: true })
  session_id!: string;

  @Column("text")
  response!: string;

  @Column("text")
  role!: string;

  @CreateDateColumn()
  created_at!: Date;
}
