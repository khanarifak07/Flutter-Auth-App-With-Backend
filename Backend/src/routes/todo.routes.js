import { Router } from "express";
import {
  createTodo,
  getTodos,
  updateTodo,
} from "../controllers/todo.controller.js";
import { verifyJWT } from "../middlewares/auth.middleware.js";
const router = Router();

router.route("/create-todo").post(verifyJWT, createTodo);
router.route("/get-todos").get(verifyJWT, getTodos);

/* router
  .route("/update-todo/users/:userId/todos/:todoId")
  .patch(verifyJWT, updateTodo);
   */
router
  .route("/update-todo/:todoId")
  .patch(verifyJWT, updateTodo);

export default router; //I can import it by name as per my choice
// export {router} // here I need to user the same name while importing this router
