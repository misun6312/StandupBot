#!/bin/bash
mix deps.get && mix escript.build
until ./standup_bot priv/config.json priv; do
    echo "Server 'standup_bot' crashed with exit code $?.  Respawning.." >&2
    sleep 1
done