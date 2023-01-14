package main

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	server "github.com/mchmarny/s3cme/cmd/server/v1"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

const (
	serviceName    = "demo"
	addressDefault = ":8080"
	logLevelEnvVar = "LOG_LEVEL"

	closeTimeout = 3
	readTimeout  = 10
	writeTimeout = 600
)

var (
	// Set at build time.
	version = "v0.0.1-default"

	contextKey key
)

type key int

type APIHandler interface {
	RootHandler(w http.ResponseWriter, r *http.Request)
}

func main() {
	initLogging()
	log.Info().Str("service", serviceName).Msg("starting server")

	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "nothing to see here, try: /api/v1\n")
	})

	h := &server.APIHandler{Version: version}

	mux.HandleFunc("/api/v1", h.RootHandler)

	address := addressDefault
	if val, ok := os.LookupEnv("PORT"); ok {
		address = fmt.Sprintf(":%s", val)
	}

	ctx := context.Background()

	run(ctx, mux, address)
}

// run starts the server and waits for termination signal.
func run(ctx context.Context, mux *http.ServeMux, address string) {
	server := &http.Server{
		Addr:              address,
		Handler:           mux,
		ReadHeaderTimeout: readTimeout * time.Second,
		WriteTimeout:      writeTimeout * time.Second,
		BaseContext: func(l net.Listener) context.Context {
			// adding server address to ctx handler functions receives
			return context.WithValue(ctx, contextKey, l.Addr().String())
		},
	}

	done := make(chan os.Signal, 1)
	signal.Notify(done, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)

	go func() {
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Error().Err(err).Msg("error listening for server")
		}
	}()
	log.Debug().Msg("server started")

	<-done
	log.Debug().Msg("server stopped")

	downCtx, cancel := context.WithTimeout(ctx, closeTimeout*time.Second)
	defer func() {
		cancel()
	}()

	if err := server.Shutdown(downCtx); err != nil {
		log.Fatal().Err(err).Msg("error shuting server down")
	}
}

func initLogging() {
	zerolog.TimeFieldFormat = zerolog.TimeFormatUnix
	zerolog.SetGlobalLevel(zerolog.InfoLevel)

	lev, ok := os.LookupEnv(logLevelEnvVar)
	if ok {
		lvl, err := zerolog.ParseLevel(lev)
		if err != nil {
			log.Warn().Err(err).Msgf("error parsing log level: %s", lev)
		} else {
			zerolog.SetGlobalLevel(lvl)
		}
	}

	log.Logger = zerolog.New(os.Stdout).With().Str("version", version).Logger()
}
