package handler

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/rs/zerolog/log"
)

// Response is the sample response struct.
type APIResponse struct {
	Name      string `json:"name,omitempty"`
	Version   string `json:"version,omitempty"`
	Message   string `json:"message,omitempty"`
	Timestamp string `json:"timestamp,omitempty"`
	Error     string `json:"error,omitempty"`
}

// Handler is the handler for the API.
type Handler struct {
	Name    string
	Version string
}

func (h *Handler) RootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	log.Info().
		Str("handler", h.Name).
		Str("version", h.Version).
		Str("handler", "root").
		Str("method", r.Method).
		Str("path", r.URL.Path).
		Msg("handling api invocation...")

	c := &APIResponse{
		Name:      h.Name,
		Version:   h.Version,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Message:   http.StatusText(http.StatusOK),
	}

	if err := json.NewEncoder(w).Encode(c); err != nil {
		log.Error().Err(err).Msgf("error encoding: %+v", c)
	}
}
