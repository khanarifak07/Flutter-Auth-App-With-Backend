//higher order function
//A function that takes another function as argument and returns a function
//()=>{()=>{}}
//()=>()=>{}

const asyncHandler = (requestHandler) => {
  return (req, res, next) => {
    Promise.resolve(requestHandler(req, res, next)).catch((error) =>
      next(error)
    );
  };
};

export { asyncHandler };

// ()=>{()=>{}}
