#!/bin/bash
cd "$(dirname "$0")/.."
docfx metadata
docfx build