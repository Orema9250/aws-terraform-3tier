import { useEffect, useState } from "react";

function App() {
  const [message, setMessage] = useState("Loading...");
  const [error, setError] = useState("");

  useEffect(() => {
    fetch("https://api.orema-devops.xyz/api/message")
      .then((response) => {
        if (!response.ok) {
          throw new Error("Failed to fetch data");
        }
        return response.json();
      })
      .then((data) => {
        setMessage(data.message);
      })
      .catch((error) => {
        setError(error.message);
      });
  }, []);

  return (
    <div>
      <h1>Vite + React Frontend</h1>

      {error ? (
        <p>{error}</p>
      ) : (
        <p>Backend response: {message}</p>
      )}
    </div>
  );
}

export default App;
