package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRootHandler(t *testing.T) {
	s := &Handler{
		Version: "1.0.0",
	}

	req, err := http.NewRequest(http.MethodGet, "/", nil)
	assert.NoError(t, err)

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(s.RootHandler)

	handler.ServeHTTP(rr, req)
	status := rr.Code
	assert.Equal(t, http.StatusOK, status)

	var r APIResponse
	err = json.NewDecoder(rr.Body).Decode(&r)
	assert.NoError(t, err)
	assert.Equal(t, s.Version, r.Version)
	assert.NotEmpty(t, r.Message)
	assert.NotEmpty(t, r.Timestamp)
	assert.Empty(t, r.Error)
}
