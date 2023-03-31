package v1

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/rs/zerolog/log"
)

type APIResponse struct {
	Version   string `json:"version,omitempty"`
	Message   string `json:"message,omitempty"`
	Timestamp string `json:"timestamp,omitempty"`
	Error     string `json:"error,omitempty"`
}

type APIHandler struct {
	Version string
}

func (h *APIHandler) RootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	log.Info().
		Str("version", h.Version).
		Str("handler", "root").
		Str("method", r.Method).
		Str("path", r.URL.Path).
		Msg("handling api invocation...")

	c := &APIResponse{
		Version:   h.Version,
		Timestamp: time.Now().UTC().Format(time.RFC3339),
		Message:   http.StatusText(http.StatusOK),
	}

	if err := json.NewEncoder(w).Encode(c); err != nil {
		log.Error().Err(err).Msgf("error encoding: %+v", c)
	}
}
