import cookieParser from "cookie-parser";
import cors from "cors";
import express from "express";
const app = express();

//cors (cross origin resource sharing) configuration as middleware
app.use(
  cors({
    origin: process.env.CORS,
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
import userRouter from "./routes/user.routes.js";
app.use("/api/v1/users", userRouter);

export { app };
