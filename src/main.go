package main

import (
	"html/template"
	"net/http"
	"strconv"
	"sync"
)

type Task struct {
	ID   int
	Name string
	Done bool
}

var tasks []Task
var idCounter int
var mu sync.Mutex

func main() {
	http.HandleFunc("/", listTasks)
	http.HandleFunc("/add", addTask)
	http.HandleFunc("/done", markTaskDone)

	http.ListenAndServe(":8080", nil)
}

func listTasks(w http.ResponseWriter, r *http.Request) {
	tmpl := template.Must(template.ParseFiles("templates/index.html"))

	mu.Lock()
	defer mu.Unlock()

	err := tmpl.Execute(w, tasks)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func addTask(w http.ResponseWriter, r *http.Request) {
	if r.Method == http.MethodPost {
		r.ParseForm()
		taskName := r.FormValue("task")

		if taskName != "" {
			mu.Lock()
			idCounter++
			tasks = append(tasks, Task{
				ID:   idCounter,
				Name: taskName,
				Done: false,
			})
			mu.Unlock()
		}
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}

func markTaskDone(w http.ResponseWriter, r *http.Request) {
	taskID := r.URL.Query().Get("id")
	id, err := strconv.Atoi(taskID)
	if err == nil {
		mu.Lock()
		for i, task := range tasks {
			if task.ID == id {
				tasks[i].Done = true
				break
			}
		}
		mu.Unlock()
	}
	http.Redirect(w, r, "/", http.StatusSeeOther)
}
