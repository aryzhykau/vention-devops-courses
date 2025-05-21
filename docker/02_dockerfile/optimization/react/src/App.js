import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [serverInfo, setServerInfo] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchServerInfo = async () => {
      try {
        const response = await fetch('/api/info');
        if (!response.ok) {
          throw new Error('Не удалось получить информацию с сервера');
        }
        const data = await response.json();
        setServerInfo(data);
        setLoading(false);
      } catch (err) {
        setError(err.message);
        setLoading(false);
      }
    };

    // Симуляция API для тестирования
    setTimeout(() => {
      setServerInfo({
        hostname: 'react-container',
        version: '1.0',
        environment: 'production',
        buildDate: new Date().toISOString()
      });
      setLoading(false);
    }, 1000);
  }, []);

  if (loading) {
    return <div className="container">Загрузка...</div>;
  }

  if (error) {
    return <div className="container error">Ошибка: {error}</div>;
  }

  return (
    <div className="container">
      <header>
        <h1>React приложение в Docker</h1>
      </header>
      
      <div className="card">
        <h2>Информация о сервере</h2>
        {serverInfo && (
          <ul>
            <li><strong>Имя хоста:</strong> {serverInfo.hostname}</li>
            <li><strong>Версия:</strong> {serverInfo.version}</li>
            <li><strong>Окружение:</strong> {serverInfo.environment}</li>
            <li><strong>Дата сборки:</strong> {serverInfo.buildDate}</li>
          </ul>
        )}
      </div>
      
      <footer>
        <p>© {new Date().getFullYear()} React Docker Example</p>
      </footer>
    </div>
  );
}

export default App; 