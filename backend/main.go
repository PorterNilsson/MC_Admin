package main

import "fmt"
import "encoding/json"
import "net/http"

func main() {
    fmt.Println("Hello, world!")

    http.HandleFunc("/user", createUserHandler)
    fmt.Println("Server running on http://localhost:8080")
    http.ListenAndServe(":8080", nil)
}

type User struct {
    Username string `json:"username"`
    Password string `json:"password"`
}

func createUserHandler(w http.ResponseWriter, r *http.Request) {
    var user User
    if err := json.NewDecoder(r.Body).Decode(&user); err != nil {
        http.Error(w, "Invalid request body", http.StatusBadRequest)
        return
    }
    fmt.Printf("User to save: Username=%s, Password=%s\n", user.Username, user.Password)
    fmt.Fprintf(w, "User %s created!", user.Username)
}