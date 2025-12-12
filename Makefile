.PHONY: help install build run preview debug clean docker-build docker-shell android-build ios-build lint format

# Variables
APP_NAME := nativescript-app
DOCKER_IMAGE := nativescript-dev
DOCKER_CONTAINER := nativescript-dev

# Couleurs pour l'output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Affiche cette aide
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║     NativeScript Development Makefile (Docker-First)      ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-25s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make [target]"
	@echo ""
	@echo "$(BLUE)Quick Start:$(NC)"
	@echo "  make up              # Lance Docker"
	@echo "  make shell           # Entre dans le container"
	@echo "  ns create MonApp     # Crée une app"
	@echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 🐳 DOCKER CORE (100% Docker Workflow)
# ═══════════════════════════════════════════════════════════════════════════════

up: ## 🚀 Lance Docker Compose (COMMANDE PRINCIPALE)
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║              🚀 Lancement de Docker Compose               ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	docker compose up -d
	@echo ""
	@echo "$(GREEN)✓ Container démarré: $(DOCKER_CONTAINER)$(NC)"
	@echo ""
	@echo "$(BLUE)Prochaines étapes:$(NC)"
	@echo "  $(YELLOW)make shell$(NC)           # Entre dans le container"
	@echo "  $(YELLOW)make status$(NC)          # Voir l'état du container"
	@echo ""

down: ## Arrête Docker Compose
	@echo "$(BLUE)→ Arrêt de Docker Compose...$(NC)"
	docker compose down
	@echo "$(GREEN)✓ Services arrêtés$(NC)"

shell: ## Entre dans le container Docker interactif
	@echo "$(BLUE)→ Entrée dans le container $(DOCKER_CONTAINER)...$(NC)"
	docker compose exec -it nativescript bash

logs: ## Affiche les logs du container
	@echo "$(BLUE)→ Logs du container...$(NC)"
	docker compose logs -f nativescript

status: ## Affiche l'état de Docker
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║                   Docker Status                           ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@docker compose ps
	@echo ""
	@echo "$(YELLOW)Pour entrer dans le container:$(NC) make shell"

# ═══════════════════════════════════════════════════════════════════════════════
# 📦 INSTALLATION & SETUP (DANS DOCKER)
# ═══════════════════════════════════════════════════════════════════════════════

install-docker: up ## Lance Docker et installe les dépendances
	@echo "$(BLUE)→ Installation des dépendances npm...$(NC)"
	docker compose exec nativescript npm install
	@echo "$(GREEN)✓ Dépendances installées$(NC)"

create-docker: ## Crée une nouvelle app NativeScript (dans Docker)
	@if [ -z "$(APP_NAME)" ]; then \
		echo "$(RED)✗ Erreur: APP_NAME non défini$(NC)"; \
		echo "$(YELLOW)Usage:$(NC) make create-docker APP_NAME=MonApp"; \
		exit 1; \
	fi
	@echo "$(BLUE)→ Création de l'app $(APP_NAME)...$(NC)"
	docker compose exec nativescript ns create $(APP_NAME) --template @nativescript-vue/template-blank@latest
	@echo "$(GREEN)✓ App créée: $(APP_NAME)$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# 🚀 DÉVELOPPEMENT (DANS DOCKER)
# ═══════════════════════════════════════════════════════════════════════════════

preview: ## Lance Preview dans Docker (QR code sur téléphone)
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║           NativeScript Preview (dans Docker)              ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo "$(YELLOW)→ Scannez le QR code avec l'app Preview sur votre téléphone$(NC)"
	@echo ""
	docker compose exec nativescript ns preview

run-android: ## Lance l'app sur Android Emulator (hot reload)
	@echo "$(BLUE)→ Lancement sur Android Emulator...$(NC)"
	docker compose exec nativescript ns run android

run-ios: ## Lance l'app sur iOS Simulator (hot reload)
	@echo "$(BLUE)→ Lancement sur iOS Simulator...$(NC)"
	docker compose exec nativescript ns run ios

run: run-android ## Alias: Lance sur Android par défaut

debug-android: ## Debug sur Android avec DevTools
	@echo "$(BLUE)→ Débogage Android...$(NC)"
	docker compose exec nativescript ns debug android

debug-ios: ## Debug sur iOS avec DevTools
	@echo "$(BLUE)→ Débogage iOS...$(NC)"
	docker compose exec nativescript ns debug ios

debug: debug-android ## Alias: Debug Android par défaut

# ═══════════════════════════════════════════════════════════════════════════════
# 🔨 BUILD & COMPILATION (DANS DOCKER)
# ═══════════════════════════════════════════════════════════════════════════════

build-android: ## Build APK release (dans Docker)
	@echo "$(BLUE)→ Build Android APK...$(NC)"
	docker compose exec nativescript ns build android --release --copy-to ./builds/
	@echo "$(GREEN)✓ APK généré dans ./builds/$(NC)"

build-android-debug: ## Build APK debug (dans Docker)
	@echo "$(BLUE)→ Build Android APK (debug)...$(NC)"
	docker compose exec nativescript ns build android --copy-to ./builds/
	@echo "$(GREEN)✓ APK généré dans ./builds/$(NC)"

build-ios: ## Build IPA release (dans Docker)
	@echo "$(BLUE)→ Build iOS IPA...$(NC)"
	docker compose exec nativescript ns build ios --release --for-device --copy-to ./builds/
	@echo "$(GREEN)✓ IPA généré dans ./builds/$(NC)"

build: build-android ## Alias: Build Android par défaut

# ═══════════════════════════════════════════════════════════════════════════════
# 🧹 CODE QUALITY (DANS DOCKER)
# ═══════════════════════════════════════════════════════════════════════════════

lint: ## Analyse le code avec ESLint (dans Docker)
	@echo "$(BLUE)→ Analyse ESLint...$(NC)"
	docker compose exec nativescript npx eslint src/ --ext .vue,.js
	@echo "$(GREEN)✓ Lint terminé$(NC)"

format: ## Formate le code avec Prettier (dans Docker)
	@echo "$(BLUE)→ Formatage du code...$(NC)"
	docker compose exec nativescript npx prettier --write "src/**/*.{vue,js,json,css}"
	@echo "$(GREEN)✓ Code formaté$(NC)"

format-check: ## Vérifie le formatage (dans Docker)
	@echo "$(BLUE)→ Vérification du formatage...$(NC)"
	docker compose exec nativescript npx prettier --check "src/**/*.{vue,js,json,css}"

# ═══════════════════════════════════════════════════════════════════════════════
# 🧹 CLEANUP
# ═══════════════════════════════════════════════════════════════════════════════

clean: ## Nettoie les fichiers générés (node_modules, builds)
	@echo "$(BLUE)→ Nettoyage local...$(NC)"
	rm -rf node_modules
	rm -rf builds
	rm -rf dist
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"

clean-docker: ## Supprime les containers et images Docker
	@echo "$(BLUE)→ Nettoyage Docker...$(NC)"
	docker compose down -v
	docker image rm $(DOCKER_IMAGE):latest 2>/dev/null || true
	@echo "$(GREEN)✓ Docker nettoyé$(NC)"

clean-all: clean clean-docker ## Nettoyage complet (local + Docker)
	@echo "$(GREEN)✓ Nettoyage complet terminé$(NC)"

prune: ## Nettoie tout (containers, images, volumes non utilisés)
	@echo "$(BLUE)→ Docker prune (attention: supprime tout inutilisé)...$(NC)"
	docker system prune -af --volumes
	@echo "$(GREEN)✓ Docker purgé$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# 📊 STATUS & INFO
# ═══════════════════════════════════════════════════════════════════════════════

info: ## Affiche les infos de l'environnement Docker
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║           Environment Info (Docker)                       ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(BLUE)Docker:$(NC)"
	@docker --version 2>/dev/null || echo "  $(RED)Docker not installed$(NC)"
	@docker compose --version 2>/dev/null || echo "  $(RED)Docker Compose not installed$(NC)"
	@echo ""
	@echo "$(BLUE)Container Status:$(NC)"
	@docker compose ps 2>/dev/null || echo "  $(RED)No containers running$(NC)"
	@echo ""
	@echo "$(BLUE)Docker Images:$(NC)"
	@docker images | grep nativescript || echo "  $(RED)No NativeScript images$(NC)"

version: ## Affiche les versions (dans Docker)
	@echo "$(BLUE)→ Versions inside Docker...$(NC)"
	docker compose exec nativescript bash -c "echo 'Node:' && node -v && echo 'npm:' && npm -v && echo 'NativeScript:' && ns --version"

# ═══════════════════════════════════════════════════════════════════════════════
# 🔄 WORKFLOWS COMPLETS (DOCKER-FIRST)
# ═══════════════════════════════════════════════════════════════════════════════

quick-start: ## Quick start 100% Docker: up + install + create
	@make up
	@make install-docker
	@make create-docker APP_NAME=$(APP_NAME)
	@echo ""
	@echo "$(GREEN)✓ Quick start terminé !$(NC)"
	@echo "$(YELLOW)Prochaines commandes:$(NC)"
	@echo "  cd $(APP_NAME)"
	@echo "  make preview"

dev: up ## Démarrage dev complet: Docker + Preview
	@echo "$(GREEN)✓ Docker est démarré$(NC)"
	@echo "$(YELLOW)→ Utilisons Preview pour le dev...$(NC)"
	@make preview

release: up ## Build release complète (Android + iOS)
	@echo "$(BLUE)→ Build de la release...$(NC)"
	@make build-android
	@make build-ios
	@echo "$(GREEN)✓ Release complète générée dans ./builds/$(NC)"

# ═══════════════════════════════════════════════════════════════════════════════
# 📝 COMMANDES AVANCÉES
# ═══════════════════════════════════════════════════════════════════════════════

rebuild: clean-docker up install-docker ## Rebuild complet (clean + up + install)
	@echo "$(GREEN)✓ Rebuild terminé$(NC)"

shell-root: ## Entre dans le container en tant que root
	docker compose exec -u root nativescript bash

exec: ## Exécute une commande dans Docker (usage: make exec CMD="votre commande")
	@if [ -z "$(CMD)" ]; then \
		echo "$(RED)✗ Erreur: CMD non défini$(NC)"; \
		echo "$(YELLOW)Usage:$(NC) make exec CMD='votre commande'"; \
		exit 1; \
	fi
	docker compose exec nativescript bash -c "$(CMD)"

# ═══════════════════════════════════════════════════════════════════════════════
# 🔗 VOLUMES & NETWORKING
# ═══════════════════════════════════════════════════════════════════════════════

volumes: ## Liste les volumes Docker
	@echo "$(BLUE)→ Volumes Docker...$(NC)"
	docker volume ls | grep nativescript

network: ## Affiche les infos réseau Docker
	@echo "$(BLUE)→ Réseau Docker...$(NC)"
	docker network inspect nativescript-dev_nativescript-network

# ═══════════════════════════════════════════════════════════════════════════════
# 🎯 SETUP INITIAL (A FAIRE UNE SEULE FOIS)
# ═══════════════════════════════════════════════════════════════════════════════

.DEFAULT_GOAL := help

init: ## ⚙️  Setup initial (à faire une fois): build Docker + install
	@echo "$(BLUE)╔════════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║              ⚙️  NativeScript Initial Setup               ║$(NC)"
	@echo "$(BLUE)╚════════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(YELLOW)1/3 Build Docker image...$(NC)"
	docker compose build
	@echo ""
	@echo "$(YELLOW)2/3 Démarrage des containers...$(NC)"
	docker compose up -d
	@echo ""
	@echo "$(YELLOW)3/3 Installation des dépendances...$(NC)"
	docker compose exec nativescript npm install
	@echo ""
	@echo "$(GREEN)✓ Setup terminé !$(NC)"
	@echo ""
	@echo "$(BLUE)Prochaines étapes:$(NC)"
	@echo "  $(YELLOW)make shell$(NC)              # Entre dans le container"
	@echo "  $(YELLOW)ns create MonApp$(NC)        # Crée une nouvelle app"
	@echo "  $(YELLOW)ns preview$(NC)              # Lance Preview"
	@echo ""
