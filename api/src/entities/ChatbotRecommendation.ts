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

  @ManyToOne("User", (user: User) => user.chatbotRecommendations)
  @JoinColumn({ name: "id_user" })
  user!: User;

  @Column("text")
  response!: string;

  @CreateDateColumn()
  created_at!: Date;
}
