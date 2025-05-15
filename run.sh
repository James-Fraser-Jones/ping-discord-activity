#!/bin/bash

# Navigate to the client directory and run the frontend dev server in the background
(cd client && npm run dev) &
FRONTEND_PID=$!
echo "Frontend dev server started with PID: $FRONTEND_PID"

# Navigate to the server directory and run the backend dev server in the background
(cd server && npm run dev) &
BACKEND_PID=$!
echo "Backend dev server started with PID: $BACKEND_PID"

# Source the .env file and run the Cloudflare tunnel in the background
if [ -f ".env" ]; then
  source .env
  if [ -n "$CLOUDFLARED_TUNNEL_TOKEN" ]; then
    cloudflared tunnel run --token "$CLOUDFLARED_TUNNEL_TOKEN" &
    TUNNEL_PID=$!
    echo "Cloudflare tunnel started with PID: $TUNNEL_PID"
  else
    echo "Warning: CLOUDFLARED_TUNNEL_TOKEN not found in .env. Cloudflare tunnel not started."
  fi
else
  echo "Warning: .env file not found. Cloudflare tunnel not started."
fi

# Keep the main script running so the background processes aren't terminated immediately
echo "All dev servers and tunnel started. Press Ctrl+C to stop all."

# Trap the SIGINT signal (Ctrl+C) to kill all background processes
trap 'kill $FRONTEND_PID $BACKEND_PID $TUNNEL_PID 2>/dev/null; echo "Stopping all processes..."; exit 130' INT

# Wait indefinitely for a signal (like Ctrl+C)
while true; do
  sleep 1
done