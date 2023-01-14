package v1

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRootHandler(t *testing.T) {
	s := &APIHandler{
		Version: "1.0.0",
	}

	req, err := http.NewRequest(http.MethodGet, "/", nil)
	assert.NoError(t, err)

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(s.RootHandler)

	handler.ServeHTTP(rr, req)
	status := rr.Code
	assert.Equal(t, http.StatusOK, status)

	var c APIResponse
	err = json.NewDecoder(rr.Body).Decode(&c)
	assert.NoError(t, err)
	assert.Equal(t, s.Version, c.Version)
	assert.NotEmpty(t, c.Message)
	assert.NotEmpty(t, c.Timestamp)
	assert.Empty(t, c.Error)
}
