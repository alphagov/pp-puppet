#!/bin/bash
eval $(<Procfile grep '^web:' | cut -d':' -f2-)
