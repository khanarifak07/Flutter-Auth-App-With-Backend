import { Todo } from "../models/todo.model.js";
import { User } from "../models/user.model.js";
import { ApiError } from "../utils/ApiError.js";
import { ApiResponse } from "../utils/ApiResponse.js";
import { asyncHandler } from "../utils/asyncHandler.js";

const createTodo = asyncHandler(async (req, res) => {
  const { title, description, complete } = req.body;

  if (!title) {
    throw new ApiError(400, "Title is required");
  }
  //get the user
  const user = await User.findById(req.user._id).select("_id");

  const todo = await Todo.create({
    title,
    description,
    complete: false,
    createdBy: user,
  });

  if (!todo) {
    throw new ApiError(500, "Error while creating todo");
  }
  console.log(todo);
  return res
    .status(200)
    .json(new ApiResponse(200, todo, "Todo created successfully"));
});

const updateTodo = async (req, res) => {
  try {
    // const userId = req.params.userId;
    const todoId = req.params.todoId;

    // Check if the user exists
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Check if the TODO exists for the specified user
    const todo = await Todo.findOne({ _id: todoId, createdBy: user });
    if (!todo) {
      return res
        .status(404)
        .json({ error: "Todo not found for the specified user" });
    }

    // Update the TODO based on your requirements
    todo.title = req.body.title; // Example: Update title from request body
    todo.description = req.body.description;
    // Update other fields as needed

    await todo.save();
    res.json(todo);
  } catch (error) {
    console.error("Error updating todo:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};

const getTodos = asyncHandler(async (req, res) => {
  //get the user
  const user = await User.findById(req.user._id);
  const todo = await Todo.find({
    createdBy: user,
  });

  return res
    .status(200)
    .json(new ApiResponse(200, todo, "All todos fetched successfully"));
});

export { createTodo, getTodos, updateTodo };
