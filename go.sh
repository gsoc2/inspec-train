#!/bin/bash

set -e

echo "--- dependencies"
. .expeditor/buildkite/cache_support.sh
install_cache_deps sudo

echo "--- pull bundle cache"
pull_bundle

echo "--- bundle"
bundle config --global github.https true
bundle config --local path vendor/bundle
bundle config set --local without tools maintenance deploy
bundle install --jobs=7 --retry=3

echo "--- push bundle cache"
push_bundle

IN=$(bundle info --path inspec 2>/dev/null)
GEM="$PWD/Gemfile"

DEFAULT_TASK="test"

echo "+++ bundle exec rake ${RAKE_TASK:-$DEFAULT_TASK}"

(
    cd "$IN"
    export SLOW=1
    export NO_AWS=1
    export CHEF_LICENSE=accept-no-persist
    export LANG=C.UTF-8 LANGUAGE=C.UTF-8
    export MT_CPU=5

    # shellcheck disable=SC2086
    bundle exec --gemfile="$GEM" rake ${RAKE_TASK:-$DEFAULT_TASK}
)
