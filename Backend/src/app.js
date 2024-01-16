import cookieParser from "cookie-parser";
import cors from "cors";
import express from "express";
const app = express();

//cors (cross origin resource sharing) configuration as middleware
app.use(
  cors({
    origin: "*",
    credentials: true,
  })
);

//configuration for json via express
app.use(
  express.json({
    limit: "16kb",
  })
);

//configuration for url encoded via express
app.use(
  express.urlencoded({
    limit: "16kb",
    extended: true,
  })
);

//configuration for cookie-parser
app.use(cookieParser());

//configration for asset via express e.g pdf, jpg, png
app.use(express.static("public"));

//import routes
import todoRouter from "./routes/todo.routes.js";
import userRouter from "./routes/user.routes.js";
//routes
app.use("/api/v1/users", userRouter);
app.use("/api/v1/todos", todoRouter);

export { app };
