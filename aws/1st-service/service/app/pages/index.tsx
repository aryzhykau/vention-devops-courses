import React, { useState, useEffect } from 'react';
import Head from 'next/head';
import styles from '../styles/Home.module.css';

interface User {
  id: number;
  username: string;
  email: string;
}

interface FileItem {
  id: number;
  filename: string;
  originalName: string;
  size: number;
  uploadedAt: string;
  url: string;
}

export default function Home() {
  const [user, setUser] = useState<User | null>(null);
  const [files, setFiles] = useState<FileItem[]>([]);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [isRegistering, setIsRegistering] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);

  // Form states
  const [loginForm, setLoginForm] = useState({ username: '', password: '' });
  const [registerForm, setRegisterForm] = useState({ 
    username: '', 
    email: '', 
    password: '', 
    confirmPassword: '' 
  });

  useEffect(() => {
    // Check if user is logged in on component mount
    const token = localStorage.getItem('token');
    if (token) {
      fetchUserProfile(token);
      fetchUserFiles(token);
    }
  }, []);

  const fetchUserProfile = async (token: string) => {
    try {
      const response = await fetch('/api/auth/profile', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (response.ok) {
        const userData = await response.json();
        setUser(userData);
        setIsLoggedIn(true);
      }
    } catch (error) {
      console.error('Error fetching user profile:', error);
      localStorage.removeItem('token');
    }
  };

  const fetchUserFiles = async (token: string) => {
    try {
      const response = await fetch('/api/files', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (response.ok) {
        const filesData = await response.json();
        setFiles(filesData);
      }
    } catch (error) {
      console.error('Error fetching files:', error);
    }
  };

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const response = await fetch('/api/auth/login', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(loginForm),
      });

      if (response.ok) {
        const { token, user: userData } = await response.json();
        localStorage.setItem('token', token);
        setUser(userData);
        setIsLoggedIn(true);
        fetchUserFiles(token);
      } else {
        alert('Login failed. Please check your credentials.');
      }
    } catch (error) {
      console.error('Login error:', error);
      alert('Login failed. Please try again.');
    }
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (registerForm.password !== registerForm.confirmPassword) {
      alert('Passwords do not match!');
      return;
    }

    try {
      const response = await fetch('/api/auth/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          username: registerForm.username,
          email: registerForm.email,
          password: registerForm.password,
        }),
      });

      if (response.ok) {
        alert('Registration successful! Please login.');
        setIsRegistering(false);
        setRegisterForm({ username: '', email: '', password: '', confirmPassword: '' });
      } else {
        const error = await response.json();
        alert(`Registration failed: ${error.message}`);
      }
    } catch (error) {
      console.error('Registration error:', error);
      alert('Registration failed. Please try again.');
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    setUser(null);
    setIsLoggedIn(false);
    setFiles([]);
  };

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setSelectedFile(e.target.files[0]);
    }
  };

  const handleFileUpload = async () => {
    if (!selectedFile) return;

    setUploading(true);
    const formData = new FormData();
    formData.append('file', selectedFile);

    try {
      const token = localStorage.getItem('token');
      const response = await fetch('/api/files/upload', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
        },
        body: formData,
      });

      if (response.ok) {
        const newFile = await response.json();
        setFiles([...files, newFile]);
        setSelectedFile(null);
        alert('File uploaded successfully!');
      } else {
        alert('File upload failed. Please try again.');
      }
    } catch (error) {
      console.error('Upload error:', error);
      alert('File upload failed. Please try again.');
    } finally {
      setUploading(false);
    }
  };

  const handleFileDownload = async (file: FileItem) => {
    try {
      const token = localStorage.getItem('token');
      const response = await fetch(`/api/files/download/${file.id}`, {
        headers: {
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = file.originalName;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      }
    } catch (error) {
      console.error('Download error:', error);
      alert('Download failed. Please try again.');
    }
  };

  return (
    <div className={styles.container}>
      <Head>
        <title>AWS 1st Service</title>
        <meta name="description" content="File upload service with AWS infrastructure" />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className={styles.main}>
        <h1 className={styles.title}>
          Welcome to <span className={styles.highlight}>AWS 1st Service</span>
        </h1>

        <p className={styles.description}>
          A modern web application deployed on AWS infrastructure
        </p>

        {!isLoggedIn ? (
          <div className={styles.authContainer}>
            {!isRegistering ? (
              <div className={styles.loginForm}>
                <h2>Login</h2>
                <form onSubmit={handleLogin}>
                  <input
                    type="text"
                    placeholder="Username"
                    value={loginForm.username}
                    onChange={(e) => setLoginForm({...loginForm, username: e.target.value})}
                    required
                  />
                  <input
                    type="password"
                    placeholder="Password"
                    value={loginForm.password}
                    onChange={(e) => setLoginForm({...loginForm, password: e.target.value})}
                    required
                  />
                  <button type="submit">Login</button>
                </form>
                <p>
                  Don't have an account?{' '}
                  <button 
                    className={styles.linkButton}
                    onClick={() => setIsRegistering(true)}
                  >
                    Register here
                  </button>
                </p>
              </div>
            ) : (
              <div className={styles.registerForm}>
                <h2>Register</h2>
                <form onSubmit={handleRegister}>
                  <input
                    type="text"
                    placeholder="Username"
                    value={registerForm.username}
                    onChange={(e) => setRegisterForm({...registerForm, username: e.target.value})}
                    required
                  />
                  <input
                    type="email"
                    placeholder="Email"
                    value={registerForm.email}
                    onChange={(e) => setRegisterForm({...registerForm, email: e.target.value})}
                    required
                  />
                  <input
                    type="password"
                    placeholder="Password"
                    value={registerForm.password}
                    onChange={(e) => setRegisterForm({...registerForm, password: e.target.value})}
                    required
                  />
                  <input
                    type="password"
                    placeholder="Confirm Password"
                    value={registerForm.confirmPassword}
                    onChange={(e) => setRegisterForm({...registerForm, confirmPassword: e.target.value})}
                    required
                  />
                  <button type="submit">Register</button>
                </form>
                <p>
                  Already have an account?{' '}
                  <button 
                    className={styles.linkButton}
                    onClick={() => setIsRegistering(false)}
                  >
                    Login here
                  </button>
                </p>
              </div>
            )}
          </div>
        ) : (
          <div className={styles.dashboard}>
            <div className={styles.header}>
              <h2>Welcome, {user?.username}!</h2>
              <button onClick={handleLogout} className={styles.logoutButton}>
                Logout
              </button>
            </div>

            <div className={styles.uploadSection}>
              <h3>Upload File</h3>
              <div className={styles.fileInput}>
                <input
                  type="file"
                  onChange={handleFileSelect}
                  disabled={uploading}
                />
                <button 
                  onClick={handleFileUpload}
                  disabled={!selectedFile || uploading}
                  className={styles.uploadButton}
                >
                  {uploading ? 'Uploading...' : 'Upload'}
                </button>
              </div>
            </div>

            <div className={styles.filesSection}>
              <h3>Your Files</h3>
              {files.length === 0 ? (
                <p>No files uploaded yet.</p>
              ) : (
                <div className={styles.filesList}>
                  {files.map((file) => (
                    <div key={file.id} className={styles.fileItem}>
                      <div className={styles.fileInfo}>
                        <span className={styles.fileName}>{file.originalName}</span>
                        <span className={styles.fileSize}>
                          {(file.size / 1024 / 1024).toFixed(2)} MB
                        </span>
                        <span className={styles.fileDate}>
                          {new Date(file.uploadedAt).toLocaleDateString()}
                        </span>
                      </div>
                      <button
                        onClick={() => handleFileDownload(file)}
                        className={styles.downloadButton}
                      >
                        Download
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}
      </main>

      <footer className={styles.footer}>
        <p>Built with Next.js and deployed on AWS infrastructure</p>
      </footer>
    </div>
  );
} 