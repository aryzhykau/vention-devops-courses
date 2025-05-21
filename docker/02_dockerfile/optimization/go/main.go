package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

// ServerInfo представляет информацию о сервере
type ServerInfo struct {
	Hostname    string    `json:"hostname"`
	GoVersion   string    `json:"go_version"`
	GOOS        string    `json:"os"`
	GOARCH      string    `json:"architecture"`
	NumCPU      int       `json:"num_cpu"`
	Environment string    `json:"environment"`
	Timestamp   time.Time `json:"timestamp"`
}

func main() {
	// Определяем порт из переменной окружения или используем 8080 по умолчанию
	port := getEnv("PORT", "8080")

	// Определяем маршруты
	http.HandleFunc("/", handleRoot)
	http.HandleFunc("/api/info", handleServerInfo)
	http.HandleFunc("/health", handleHealth)

	// Запускаем сервер
	fmt.Printf("Сервер запущен на порту %s...\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Ошибка при запуске сервера: %v", err)
	}
}

// handleRoot обрабатывает корневой маршрут и возвращает простое сообщение
func handleRoot(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Привет от Go-приложения в Docker!")
}

// handleServerInfo возвращает информацию о сервере в формате JSON
func handleServerInfo(w http.ResponseWriter, r *http.Request) {
	hostname, _ := os.Hostname()
	environment := getEnv("ENVIRONMENT", "development")

	info := ServerInfo{
		Hostname:    hostname,
		GoVersion:   runtime.Version(),
		GOOS:        runtime.GOOS,
		GOARCH:      runtime.GOARCH,
		NumCPU:      runtime.NumCPU(),
		Environment: environment,
		Timestamp:   time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(info)
}

// handleHealth проверяет состояние здоровья приложения
func handleHealth(w http.ResponseWriter, r *http.Request) {
	response := map[string]string{
		"status": "ok",
		"time":   time.Now().Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

// getEnv получает значение переменной окружения или значение по умолчанию
func getEnv(key, defaultValue string) string {
	value, exists := os.LookupEnv(key)
	if !exists {
		return defaultValue
	}
	return value
} 