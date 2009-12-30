#!/bin/sh
rake gems:install
RAILS_ENV=test rake gems:install
rake cruise