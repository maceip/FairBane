name: deploy new notary-server on azure sgx

on:
  release:
    types: [published]
    branches:
      - release

jobs:
  update-caddyfile:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Set up environment
        run: |
          sudo apt-get update
          sudo apt-get install -y jq

      - name: Extract release information
        env:
          RELEASE_TAG: ${{ github.event.release.tag_name }}
        run: |
          # Paths to files
          CADDYFILE_PATH='cd-scripts/tee/azure/Caddyfile'
          PORT_FILE='ports.yml'
          START_PORT=8081

          # Create ports.txt if it doesn't exist
          if [ ! -f "$PORT_FILE" ]; then
            echo $START_PORT > $PORT_FILE
          fi

          # Check if the release tag already has a port assigned
          ASSIGNED_PORT=$(grep "${RELEASE_TAG}" $PORT_FILE | awk '{print $2}')

          if [ -z "$ASSIGNED_PORT" ]; then
            # Find the next available port if this release tag doesn't have one
            NEXT_PORT=$(($(tail -n 1 $PORT_FILE | awk '{print $2}') + 1))
            echo "${RELEASE_TAG} ${NEXT_PORT}" >> $PORT_FILE
          else
            NEXT_PORT=$ASSIGNED_PORT
          fi

          # Check if the tee.notary.dev block already exists in the Caddyfile
          if ! grep -q "tee.notary.dev {" $CADDYFILE_PATH; then
            # Add the main block to the Caddyfile if it doesn't exist
            echo -e "tee.notary.dev {\n}" >> $CADDYFILE_PATH
          fi

          # Insert the reverse proxy entry for the new release tag
          sed -i "/tee.notary.dev {/a \ \ \ \ reverse_proxy /${RELEASE_TAG}* localhost:${NEXT_PORT} {" $CADDYFILE_PATH

      - name: Commit and push updated Caddyfile
        run: |
          git config user.name github-actions
          git config user.email github-actions@github.com
          git add $CADDYFILE_PATH $PORT_FILE
          git commit -m "azure tee release: ${RELEASE_TAG}"
          git push

      - name: Deploy updated Caddyfile to server
        uses: appleboy/scp-action@v0.1.3
        with:
          host: ${{ secrets.AZURE_TEE_BUILD_HOST }}
          username: ${{ secrets.AZURE_TEE_BUILD_USERNAME }}
          key: ${{ secrets.AZURE_TEE_BUILD_KEY }}
          source: "cd-scripts/tee/azure/Caddyfile"
          target: "/etc/caddy/Caddyfile"

      - name: Reload Caddy on server
        uses: appleboy/ssh-action@v0.1.3
        with:
          host: ${{ secrets.AZURE_TEE_BUILD_HOST }}
          username: ${{ secrets.AZURE_TEE_BUILD_USERNAME }}
          key: ${{ secrets.AZURE_TEE_BUILD_KEY }}
          script: |
            caddy reload
