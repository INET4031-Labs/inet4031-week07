# INET 4031: Systems Administration -- Full Lab Curriculum (Proposed)

> **PROPOSAL STATUS:** This document is a draft proposal for professor review. It has not been approved or finalized. Present it as a design candidate, not course material.

> **ARCHITECTURE ASSUMPTION (read before using any content below):** Every week from Week 3 onward depends on the university's container platform permitting `--privileged` mode for Docker containers. This has **not been confirmed** by the professor. If privileged mode is unavailable, the container-per-team model described here fails entirely and the course falls back to individual student VMs. Do not treat this environment as decided until the professor confirms it.

---

## Course Structure Overview

**Environment:** One privileged Docker container per team (4-6 students), shared for the entire semester. The container runs a nested Docker daemon. k3d creates a local k3s cluster by launching k3s node containers inside the team container.

**Application:** Python Flask API + PostgreSQL + Nginx incident tracking service. Data model: title, status (open/resolved), timestamp, description. Application code is provided to students. Students containerize and operate it.

**Toolset:** Docker, k3d (not raw k3s), OpenTofu (not Terraform), kompose, Ansible, GitHub Actions, MinIO, restic, Prometheus/Grafana, k6.

**Sprint rhythm:** 7 sprints across 14 weeks. Odd weeks are synchronous (in-person). Even weeks are asynchronous. Roles rotate each sprint: Scrum Master, System Admin, QA, Developer(s).

**Team Google Doc:** Each team creates one shared Google Doc using their UMN Google Workspace account in Week 1. This doc is permanent, separate from the GitHub repo, and is used for all reflection question answers across the entire semester submitted into Canvas.

**Ansible thread:** Weeks 1-4 each add that week's tool to `ansible/site.yml`. At Demo Day (Week 14), the professor wipes the team container and `ansible-playbook site.yml` rebuilds the full toolchain in one run. This is the capstone justification for Ansible's presence in the curriculum.

---

## Week 1: Setup and Team Formation

**Sprint 1 Kickoff | Synchronous**

### Overview

In this lab, you will form your team, assign Sprint 1 roles, establish your shared GitHub repository, and verify access to your team's shared container environment. You will also initialize the Ansible playbook that will grow throughout the semester and serve as the blueprint for rebuilding your entire environment on Demo Day. This course models how real operations teams work: rotating responsibilities, tracking work in sprints, and treating infrastructure as code from day one. After completing this lab, you will have a functioning team charter, a structured GitHub repository, and a working Ansible playbook committed to version control that installs Docker and configures your baseline container environment.

### Learning Objectives

- Assign team roles and build a 7-sprint rotation schedule that satisfies coverage requirements
- Create and structure a GitHub repository for a semester-long infrastructure project
- Verify access to a shared privileged team container and document its baseline state
- Initialize an Ansible playbook targeting localhost that runs idempotently
- Apply the sprint ceremony structure to open Sprint 1 with a defined backlog

### Prerequisites

- A GitHub account
- Access to the team container provisioned by the professor (SSH credentials or exec method provided in class)
- No prior tool experience required for this lab

### Sprint 1 Kickoff

This is the first synchronous lab session. There is no prior sprint to review. Use this session to establish the foundation every future sprint depends on: who does what, where work lives, and how your environment is built. Work that is not tracked or reproducible from your repository does not count.

---

### Part 1: Team Roles and Sprint Structure

Before assigning roles, discuss the following questions as a group. You do not need to write your answers yet. Record your answers in the team Google Doc (created in Part 3) after the lab session.

**Discussion (whole group, before role assignments):**

1. Why would an operations team benefit from rotating responsibilities rather than fixed specialization?
2. In infrastructure work, what does "QA" mean when the deliverable is a config file or a deployment manifest?
3. How does a Scrum Master differ from a project manager? Why does that distinction matter on a team that operates systems?

After the discussion, assign roles for Sprint 1.

**Roles for this course:**

| Role | Count | Primary responsibilities |
|---|---|---|
| Scrum Master | 1 | Runs sprint ceremonies, owns the sprint board, unblocks teammates |
| System Admin | 1 | Owns environment configuration, leads infrastructure steps |
| QA | 1 | Runs all validation checks, signs off before deliverables are submitted |
| Developer | 2-3 | Writes configuration files, sets up tooling, follows lab steps |

**Step 1.** Create a GitHub repository and add your teammates as collaborators. As a group, decide who holds each role for Sprint 1. Write it down now. You will commit this to the repo in Part 2.

**Step 2.** Build your 7-sprint rotation schedule.

Every team member must hold Scrum Master, System Admin, and QA at least once across the seven sprints. With 4-6 members and 7 sprints, plan this now to avoid conflicts later. Create your  the table in your Google document in the following format:

```
Sprint 1: Scrum Master = ___, System Admin = ___, QA = ___, Developers = ___
Sprint 2: Scrum Master = ___, System Admin = ___, QA = ___, Developers = ___
Sprint 3: Scrum Master = ___, System Admin = ___, QA = ___, Developers = ___
Sprint 4: Scrum Master = ___, System Admin = ___, QA = ___, Developers = ___
Sprint 5: Scrum Master = ___, System Admin = ___, QA = ___, Developers = ___
Sprint 6: Scrum Master = ___, System Admin = ___, QA = ___, Developers = ___
Sprint 7: Scrum Master = ___, System Admin = ___, QA = ___, Developers = ___
```

**Step 3.** Agree on your team's communication norms. Decide the following before moving on:

- Where your team communicates outside of class (Discord, Slack, group text, etc.)
- How you will notify each other when something is merged or when something breaks
- What your expected response time is when a teammate is blocked on a task

Record these norms. You will commit them to the repo in Part 2.

---

### Part 2: Version Control and Project Tracking

Before writing any configuration, get your version control environment in order. Every artifact you create in this course lives in the repo, or it does not exist.

**Step 1.** Complete the following two GitHub Skills tutorials before creating your team repo. These cover the basics you will use throughout the semester.

- [Introduction to GitHub](https://github.com/skills/introduction-to-github)
- [Introduction to Git](https://github.com/skills/introduction-to-git)

One team member can work through these while others handle role planning, but every member should review the material before the end of lab.

**Step 2.** One team member creates the repository. Name it exactly:

```
inet4031-team-[number]
```

Replace `[number]` with your assigned team number (provided by the professor). Set visibility to **Public**. Add all teammates as collaborators with **Write** access under Settings > Collaborators.

**Step 3.** Clone the repository into your team container. The System Admin leads this step while others verify the output.

```bash
git clone https://github.com/[your-org-or-username]/inet4031-team-[number].git
cd inet4031-team-[number]
```

You should see an empty repository directory with no files listed.

**Step 4.** Create the top-level directory structure. This structure anticipates tooling you will add in future sprints.

```bash
mkdir -p ansible week-1 week-2 week-3 week-4 week-5 week-6 week-7 week-8 week-9 scripts
```

**Step 5.** Create `README.md` at the repo root. Include: your team name, team roster (names and UMN IDs), a one-paragraph project description, and a placeholder line for the Google Doc link. You will fill in the link during Part 3.

**Step 6.** Create `team-charter.md` at the repo root. This file must include all of the following:

- Team name and full roster
- Sprint 1 role assignments
- Full 7-sprint rotation schedule
- One-sentence description of each role
- Communication norms from Part 1 Step 3
- Three decisions the team made about how you will operate the container together (for example: who is responsible for committing playbook changes, how you will handle merge conflicts, what your team will do if the container behaves unexpectedly)

**Step 7.** Commit and push both files.

```bash
git add README.md team-charter.md
git commit -m "feat: add README and team charter for Sprint 1"
git push origin main
```

You should see output ending in `main -> main`. If you see an authentication error, confirm your GitHub credentials are configured on the container.

**Step 8.** The Scrum Master creates a GitHub Project board linked to the repository. Add four columns: Backlog, In Progress, In Review, Done.

**Step 9.** Open Sprint 1 tickets on the board. Create at minimum one ticket per Part of this lab, and one ticket for each major task in Week 2. The Scrum Master owns the board. Developers and the System Admin pull tickets as they work through the steps.

**Discussion (answer in Google Doc, Sprint 1 section):**

- You committed a team charter and project structure before writing a single line of configuration. Why does this ordering matter on a team that operates shared infrastructure?
- What would happen if two teammates both pushed changes to `team-charter.md` at the same time? What does Git do in that situation, and whose job is it to resolve it?

---

### Part 3: Container Environment and Ansible Bootstrap

Your team has been assigned one shared container for the entire semester. This replaces individual VMs. Every member of your team can access it simultaneously.

> **Enterprise Pattern:** Large infrastructure teams often share environment access rather than maintaining identical individual environments. The tradeoff is coordination overhead in exchange for consistency. Your shared team container makes that tradeoff explicit.

**Step 1.** Every team member independently verifies they can access the team container using the method the professor provided (SSH or `docker exec`). Do not move forward until everyone on the team can get in.

**Step 2.** The System Admin runs the following commands to document the baseline state of the container. Every other team member should be watching and noting what they see.

Check the operating system:

```bash
cat /etc/os-release
```

Check available disk space:

```bash
df -h
```

Check which course-relevant tools are already installed:

```bash
which docker git python3 curl ansible
```

Check the Docker daemon status (this is the nested Docker daemon running inside the container):

```bash
docker info
```

**Step 3.** Record your observations in `team-charter.md` under a new section called "Container Baseline." Include: OS name and version, total disk space available, and which of the listed tools are already installed versus missing.

Commit the update:

```bash
git add team-charter.md
git commit -m "docs: add container baseline observations to charter"
git push origin main
```

**Step 4.** Install Ansible inside the container if it is not already present.

```bash
apt-get update && apt-get install -y ansible
```

Verify the installation succeeded:

```bash
ansible --version
```

You should see a version line starting with `ansible [core` or `ansible 2.`. If you see "command not found," check whether `apt-get` ran without errors and retry.

**Step 5.** Create the Ansible directory structure inside the repo. The System Admin creates this while Developers observe and QA prepares to verify the output.

```bash
mkdir -p ansible/roles
touch ansible/site.yml ansible/inventory
```

**Step 6.** Configure the Ansible inventory file to target localhost. Open `ansible/inventory` and add:

```ini
[local]
localhost ansible_connection=local
```

This tells Ansible to run tasks on the same machine where it is invoked, without trying to SSH anywhere.

**Step 7.** Create the initial `ansible/site.yml`. This playbook will grow one role per week through Week 4. Right now it does one thing: ensure the baseline environment is configured.

Open `ansible/site.yml` and copy & paste the following:

```yaml
---
- name: Baseline environment setup
  hosts: localhost
  connection: local
  become: yes

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600

    - name: Ensure baseline packages are installed
      apt:
        name:
          - curl
          - git
          - vim
          - python3
          - python3-pip
        state: present

    - name: Ensure Docker is installed
      apt:
        name: docker.io
        state: present
```

**Step 8.** Run the playbook to verify it executes without errors.

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Look for the `PLAY RECAP` section at the bottom of the output. You should see `failed=0` and `unreachable=0`.

**Step 9.** Run the playbook a second time without making any changes.

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

This time, every task should report `ok` rather than `changed`. This confirms the playbook is idempotent: running it twice produces the same end state as running it once.

> **Enterprise Pattern:** Idempotency is a core requirement for automation in production. If a playbook makes changes on every run, it is not safe to run automatically on a schedule. The `ok` versus `changed` distinction in Ansible output is how you verify idempotency before trusting a playbook in production.

**Step 10.** Commit the Ansible files to the repo.

```bash
git add ansible/
git commit -m "feat: initialize site.yml with baseline environment play"
git push origin main
```

**Step 11.** Create the Google Doc for your team. Open Google Drive using your UMN Google Workspace account (not personal Gmail). Create a new Google Doc titled:

```
INET 4031 Team [number] Reflections
```

 Add the doc's URL (Ensure that the copy link allows access to all users within University of Minnesota) to `README.md` under a "Team Documents" section. Commit and push the update.

```bash
git add README.md
git commit -m "docs: add Google Doc link to README"
git push origin main
```

Answer the Part 1 and Part 2 discussion questions in the Google Doc now, under a section labeled "Sprint 1 Reflections."

**Discussion (answer in Google Doc, Sprint 1 section):**

- What would happen to your work if this container were wiped right now? How much of what you built exists in a form that can be recreated automatically?
- What is the difference between a manual setup process and an automated one? Which one is reproducible across all team members, and which one depends on someone remembering what they did?

---

### Storage Check

Run these two commands inside the container and record the output in your Google Doc under a section labeled "Week 1 Storage Baseline."

```bash
df -h
docker system df
```

The `df -h` output shows filesystem usage on the container's file system. The `docker system df` output shows space used by Docker images, containers, and volumes managed by the Docker daemon. At this point both should show minimal usage. You will compare against these numbers at the end of each future week.

Note: starting in Week 3, you will install k3d, which uses a separate containerd image store that `docker system df` does not report. Both tools consume disk space. More on this in Week 3.

---

### Validation Checks

**QA runs all validation checks.** Every other team member watches and verifies the output matches what is expected below.

#### Validation Check: All Team Members Can Access the Container

Every team member must run this individually from their own machine or terminal connected to the Docker container:

```bash
whoami
hostname
```

Expected output: a username and the container hostname provided by the professor. If any team member cannot connect, stop and resolve access before moving on.

#### Validation Check: Repository Structure Is Correct

Run from the repo root inside the container:

```bash
ls -1
```

Expected output includes at minimum: `README.md`, `ansible`, `scripts`, `team-charter.md`, `week-1`, `week-2`. If any directory is missing, create it and push the change before running the check script.

#### Validation Check: Ansible Playbook Is Idempotent

Run the playbook twice in a row without making any changes between runs:

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
ansible-playbook -i ansible/inventory ansible/site.yml
```

Expected output of the second run: every task shows `ok` in the status column, not `changed`. The `PLAY RECAP` line should show `changed=0`.

If any task shows `changed` on the second run, that task is not idempotent. Identify which task it is and correct the playbook before submitting.

#### Validation Check: Google Doc Is Linked and Shared

Open `README.md` and confirm the Google Doc URL is present. Open the URL and confirm: the doc is accessible to those within the University of  Minnesota, and it contains at least the Sprint 1 reflection section with answers to Parts 1, 2, and 3 discussion questions.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week1.sh
```

Expected: all checks pass. If any check fails, the script will identify which requirement is not met. Fix the issue and re-run before marking deliverables complete.

---

### Deliverables

- `README.md` committed to repo root (team name, roster, Google Doc link filled in)
- `team-charter.md` committed to repo root (all required sections present, including container baseline)
- `ansible/site.yml` committed (runs without error, passes the idempotency check)
- `ansible/inventory` committed
- Google Doc created with UMN-wide access, doc URL in `README.md`
- Google Doc contains Sprint 1 reflection answers for Parts 1, 2, and 3
- All validation checks pass

**Screenshot requirements (add to the team Google Doc):**

- **Screenshot 1:** Terminal output showing each team member's `whoami` result from inside the container
- **Screenshot 2:** `ansible-playbook` output from the second run showing `changed=0` in the PLAY RECAP

---

### Sprint Backlog: Preparing for Week 2

Week 2 is asynchronous. Before leaving today's lab session, the Scrum Master ensures the sprint board has the following tickets open in the Backlog column.

Tickets to open:

- Define Docker Compose services (Nginx, Flask, PostgreSQL)
- Configure named network and named volume
- Set up `.env` pattern for credentials
- Add `app-stack` role to `ansible/site.yml`
- Run Week 2 validation checks and check script
- Update Google Doc with Week 2 reflections and storage check

---

---

## Week 2: Building Your Three-Tier Application Stack

**Sprint 1 Async | Due before Sprint 1 Review**

### Overview

In this lab, your team containerizes and operates the incident tracking application: a Python Flask API connected to a PostgreSQL database and fronted by an Nginx reverse proxy. The application code is provided. Your job is to write the Docker Compose configuration that wires the three services together, handle startup ordering, configure data persistence, and manage credentials without hardcoding them. You will also extend the Ansible playbook to include the application stack, moving one step closer to the full automated rebuild your team will demonstrate at the end of the semester. After completing this lab, you will have a running three-tier application stack defined entirely in code, with credentials handled through environment variable injection and data persistence verified across container restarts.

### Learning Objectives

- Write a Docker Compose file that defines a three-tier application with health checks and explicit dependency ordering
- Configure a named network and named volume for service communication and data persistence
- Implement an environment variable pattern for credential management that never commits secrets to version control (GitHub)
- Verify that the application stack survives container restarts without data loss
- Extend the Ansible playbook with a role that brings up the Docker Compose stack as part of the rebuild process

### Prerequisites

- Week 1 complete: GitHub repo exists, team container is accessible to all members, `ansible/site.yml` is committed and runs clean
- Docker is running inside the team container (`docker info` returns output without error)
- Application source code provided by the professor is available at the path specified in lab materials

### Sprint 1 Context

This is async work. The Scrum Master owns the sprint board and keeps it updated. Pull tickets as you work. Coordinate so each role contributes to its section. **No single team member should complete the entire lab.**

- **System Admin:** leads Part 1 (service definition) and Part 3 Ansible addition
- **Developers:** write and test the Docker Compose file, configure networking and volumes in Part 2
- **QA:** runs all validation checks, is the final approver before deliverables are marked Done
- **Scrum Master:** keeps the board current, resolves blockers, participates in at least one Part

---

### Part 1: Define Your Services

The incident tracking application has three services that must run together. You are not writing the application code. You are writing the configuration that runs it.

**The three services:**

- **PostgreSQL** (`db`): the database. Stores incident records. Must finish initializing before Flask can connect.
- **Flask** (`flask`): the API. Reads and writes incidents. Must be healthy before Nginx routes traffic to it.
- **Nginx** (`nginx`): the reverse proxy. Handles incoming requests and forwards them to Flask. Comes up last.

**Step 1.** Inside your team container, navigate to the repo and create the directory for this week's files.

```bash
cd inet4031-team-[number]
mkdir -p week-2/app
```

**Step 2.** Place the provided application source code in `week-2/app/`. The professor will specify the exact path or repository URL. Confirm the files are present.

```bash
ls week-2/app/
```

Expected output includes at minimum: `Dockerfile`, the Flask application file ( `app.py`), and `requirements.txt`. If any of these are missing, check with the professor before continuing.

**Step 3.** Create `week-2/docker-compose.yml` and copy and paste the following Docker compose file into your repository. Begin with the database service only.

```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**Step 4.** Add the Flask service to `docker-compose.yml` below the `db` definition.

```yaml
  flask:
    build: ./app
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@db:5432/${POSTGRES_DB}
    depends_on:
      db:
        condition: service_healthy
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 10s
      timeout: 5s
      retries: 3
```

**Step 5.** Create `week-2/nginx.conf`. Nginx needs this file to know where to send traffic.

```nginx
server {
    listen 80;

    location / {
        proxy_pass http://flask:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**Step 6.** Add the Nginx service to `docker-compose.yml`.

```yaml
  nginx:
    image: nginx:alpine
    ports:
      - "${HOST_PORT:-8080}:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      flask:
        condition: service_healthy
    networks:
      - app-network
```

**Discussion (answer in Google Doc, Sprint 1 Week 2 section):**

- What order do these services need to start in? Can Nginx come up before Flask is ready? Can Flask connect to PostgreSQL before it finishes initializing? What does `condition: service_healthy` enforce that plain `depends_on` does not?
- What is the difference between a container being "running" and a container being "healthy"? Why does that distinction matter when one service depends on another?

---

### Part 2: Networking and Persistence

Without explicit network and volume configuration, services cannot reliably find each other and data disappears when containers stop.

**Step 1.** Add the top-level `networks` and `volumes` definitions to the bottom of `week-2/docker-compose.yml`.

```yaml
networks:
  app-network:
    driver: bridge

volumes:
  db-data:
```

**Step 2.** You need a `.env` file before you can start the stack. Copy the example file as a placeholder.

```bash
cp week-2/.env.example week-2/.env
```

Ensure your `.env` has the following contents. If not, then copy and paste it into your file:

```
POSTGRES_DB=statustracker
POSTGRES_USER=appuser
POSTGRES_PASSWORD=changeme
HOST_PORT=8080
```

**Step 3.** Start the stack for the first time.

```bash
cd week-2
docker compose up -d
```

Wait 30 seconds for health checks to run before checking status.

**Step 4.** Check the status of all containers.

```bash
docker compose ps
```

All three containers should show `healthy` in the Status column. If any show `starting` after 60 seconds, check the logs for that service.

**Step 5.** If any container is not healthy, check its logs to find the error.

```bash
docker compose logs db
docker compose logs flask
docker compose logs nginx
```

**Step 6.** Test that data persists across a container restart. First, create a test incident by calling the Flask API through Nginx.

```bash
curl -X POST http://localhost:8080/incidents \
  -H "Content-Type: application/json" \
  -d '{"title": "Persistence check", "status": "open", "description": "this should survive a restart"}'
```

Note the ID value in the response.

**Step 7.** Restart only the PostgreSQL container (not the whole stack).

```bash
docker compose restart db
```

Wait 20 seconds, then retrieve all incidents.

```bash
curl http://localhost:8080/incidents
```

Your test incident should appear in the response. If it does not, the named volume is not working correctly.

**Step 8.** Stop the stack and bring it back up without destroying the volume.

```bash
docker compose down
docker compose up -d
```

After the stack is healthy, retrieve incidents again. Your test incident should still be present.

**Step 9.** Observe what happens when you destroy the volume intentionally.

```bash
docker compose down -v
docker compose up -d
```

Retrieve incidents after the stack is healthy. The database is empty. This is expected. The `-v` flag removes named volumes along with containers.

> **Enterprise Pattern:** In production, `docker compose down -v` is a destructive operation that causes data loss. Operations teams protect against accidental data loss by running database backups before planned downtime and by separating the database lifecycle from the application lifecycle. You will work with backup tooling in Sprint 4.

**Discussion (answer in Google Doc):**

- What happens to your database data after `docker compose down`? What about `docker compose down -v`? When would each command be appropriate to use?
- Nginx refers to Flask as `flask:5000` in its configuration. How does Docker resolve the hostname `flask` to an IP address? What would happen if you renamed the Flask service to `api` but forgot to update `nginx.conf`?

---

### Part 3: Environment Configuration and Ansible

**Step 1.** Add `.env` to `.gitignore` so it is never committed. If `.gitignore` is not already present in your repository, then create the file in your repo root and add `.env` to it.

```bash
echo "week-2/.env" >> .gitignore
```

Verify the rule is working:

```bash
git check-ignore -v week-2/.env
```

Expected output: a line showing which `.gitignore` rule matches `week-2/.env`.

Commit the `.gitignore` update:

```bash
git add .gitignore week-2/.env.example
git commit -m "chore: ignore .env files, add .env.example for week-2"
git push origin main
```

> **Enterprise Pattern:** The `.env.example` pattern is a standard way to document required configuration without committing secrets. In production, these values would come from a secrets manager rather than a local file, but the pattern is the same: document what is needed, inject actual values at runtime, never store actual secrets in version control.

**Step 2.** Add the `app-stack` role to `ansible/site.yml`. This role will bring up the Docker Compose stack as part of the automated rebuild playbook that runs on Demo Day.

Create the role directory structure:

```bash
mkdir -p ansible/roles/app-stack/tasks
```

Create `ansible/roles/app-stack/tasks/main.yml`:

```yaml
---
- name: Ensure .env file exists for app stack
  copy:
    src: "{{ playbook_dir }}/../week-2/.env.example"
    dest: "{{ playbook_dir }}/../week-2/.env"
    force: no

- name: Bring up the Docker Compose application stack
  community.docker.docker_compose_v2:
    project_src: "{{ playbook_dir }}/../week-2"
    state: present
  become: yes
```

The `force: no` on the copy task means the playbook will create `.env` from the example if it does not exist, but will not overwrite an existing `.env`.

**Step 3.** Add the new role to `ansible/site.yml`. Open the file and append a second play below the existing baseline play.

```yaml
- name: Deploy application stack
  hosts: localhost
  connection: local
  become: yes

  roles:
    - app-stack
```

**Step 4.** Install the Ansible collection that provides the `docker_compose_v2` module.

```bash
ansible-galaxy collection install community.docker
```

**Step 5.** Run the full playbook to confirm both plays execute without error.

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Check the `PLAY RECAP` section. Both plays should show `failed=0` and `unreachable=0`.

**Step 6.** Commit all Ansible changes.

```bash
git add ansible/
git commit -m "feat: add app-stack role to site.yml for Docker Compose stack"
git push origin main
```

**Discussion (answer in Google Doc):**

- Where should credentials live in a containerized application? What are the risks of hardcoding them directly in `docker-compose.yml`?
- If a teammate cloned your repo and ran `docker compose up`, what would they need to provide that is not in the repo? What file should they consult to know exactly what is required?

---

### Storage Check

Run these commands inside the team container and record the output in your Google Doc under "Week 2 Storage Check."

```bash
df -h
docker system df
```

Compare `docker system df` output to your Week 1 baseline. You should now see images, at least three containers, and one named volume listed.

---

### Validation Checks

#### Validation Check: All Three Services Are Healthy

Run from inside the `week-2/` directory:

```bash
docker compose ps
```

Expected output shows three rows, each with `healthy` in the Status column. If a service shows `starting` after 60 seconds: run `docker compose logs [service-name]`.

#### Validation Check: Nginx Is Reachable on the Mapped Port

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/
```

Expected output: `200`. If you see `000` or `Connection refused`: Nginx is not running or the port mapping is wrong.

#### Validation Check: Data Persists Across Container Restart

Create a test incident, restart the database container only, retrieve all incidents, and confirm your record is present.

#### Validation Check: Ansible Playbook Runs Clean

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Expected: `PLAY RECAP` shows `failed=0` and `unreachable=0` for both plays.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week2.sh
```

---

### Deliverables

- `week-2/docker-compose.yml` committed (all three services, health checks, named network, named volume)
- `week-2/.env.example` committed
- `week-2/nginx.conf` committed
- `.gitignore` updated so `week-2/.env` is excluded
- `week-2/README.md` committed (explains the stack, how to bring it up, what `.env` values are required)
- `ansible/site.yml` updated with the `app-stack` role play
- `ansible/roles/app-stack/tasks/main.yml` committed
- All validation checks pass
- `./scripts/check-week2.sh` runs clean inside the container
- Google Doc updated with Sprint 1 Week 2 reflection answers and Week 2 storage check values

**Screenshot requirements:**

- **Screenshot 1:** `docker compose ps` showing all three services with `healthy` status
- **Screenshot 2:** `curl` response from the `/health` endpoint
- **Screenshot 3:** Persistence check: incident created, database container restarted, incident retrieved successfully
- **Screenshot 4:** `ansible-playbook` PLAY RECAP showing `failed=0` for both plays
- **Screenshot 5:** `./scripts/check-week2.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. What did you learn about container startup ordering that you did not expect? If you removed `condition: service_healthy` and left only `depends_on: db`, what would change about when Flask starts?
2. If your team's container were wiped today, which parts of this stack could be rebuilt automatically from your repo? Which parts would require manual steps, and why?
3. Docker Compose manages containers on one machine. What would break if you needed this application to run across multiple machines? What problem does that create for the PostgreSQL container in particular?
4. Your `.env` file holds database credentials. Trace the path of those credentials: where are they stored on disk, how do they reach the running container process, and at what points could they be exposed?

---

---

## Week 3: Container Orchestration with k3d

**Sprint 2 Kickoff | Synchronous**

> **Assumption:** This lab requires k3d to create k3s nodes as Docker containers inside your team container. This depends on `--privileged` mode being available on the university's container platform. If your team's container does not support nested Docker, k3d cannot create its cluster nodes and this lab will not work as written. Confirm with your instructor before continuing.

### Overview

In this lab, you move the incident tracking application from Docker Compose into Kubernetes, running on a local k3d cluster inside your team container. k3d creates k3s nodes as Docker containers, giving you a full Kubernetes environment without a separate cluster. You will use kompose to translate your Docker Compose file into Kubernetes manifests, identify and fix two problems in the generated output, and deploy a working application into the cluster. After completing this lab, you will have the incident tracker running in Kubernetes with fixed manifests committed to your repository, and the k3d setup added to your Ansible playbook.

### Learning Objectives

- Create a k3d cluster inside a Docker-in-Docker environment and obtain a working kubeconfig
- Translate a Docker Compose file to Kubernetes manifests using kompose
- Identify and fix insecure defaults in generated manifest output (plaintext credentials and Recreate strategy)
- Deploy a three-tier application to Kubernetes and verify all pods are healthy
- Extend the Ansible playbook with a k3d cluster setup role

### Prerequisites

- Week 2 complete: Docker Compose stack is running inside your team container
- Docker daemon is running inside the team container (nested Docker)
- `kubectl` and `k3d` available in the container, or installable

### Sprint Review: Sprint 1

**Step 1.** Open your team's GitHub project board. Move all completed Sprint 1 items to Done. For any incomplete items, add a one-sentence note explaining what was not finished.

**Step 2.** Each team member answers these three questions. The Scrum Master facilitates. Record answers in your Google Doc under "Sprint 1 Close."

- What did you contribute to Sprint 1?
- What is the most important thing the team shipped?
- What would you do differently if Sprint 1 started again?

**Step 3.** Run the container state checkpoint.

```bash
docker ps
docker compose -f week-2/docker-compose.yml ps
git log --oneline -5
```

Paste the output into your Google Doc under "Sprint 2 Kickoff -- Environment State."

### Sprint 2 Kickoff

**Step 4.** Assign Sprint 2 roles from your rotation schedule. Record the assignments.

**Step 5.** Create a Sprint 2 milestone on your GitHub project board. Add Week 3 deliverable items as issues before proceeding.

---

### Part 1: Create a k3d Cluster

> **Background:** k3d is a wrapper that runs k3s (a lightweight Kubernetes distribution) inside Docker containers. When you create a k3d cluster inside your team container, k3d launches Docker containers that act as k3s nodes. Your team container's Docker daemon manages those node containers. This gives you a real Kubernetes API server and full `kubectl` access without needing a separate VM or cloud environment.

**Step 6.** Install k3d inside the team container if it is not already available.

```bash
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

Verify the installation.

```bash
k3d version
```

You should see version output starting with `k3d version`.

**Step 7.** Create a k3d cluster. The `--port` flag maps port 80 on the LoadBalancer to port 8080 on the team container host.

```bash
k3d cluster create myapp --agents 2 --port "8080:80@loadbalancer"
```

This takes one to two minutes. k3d creates three containers inside your team container: one server node and two agent nodes.

**Step 8.** Verify all cluster nodes are ready.

```bash
kubectl get nodes
```

Expected output: three rows, all with `Ready` in the STATUS column.

```
NAME                  STATUS   ROLES                  AGE   VERSION
k3d-myapp-server-0    Ready    control-plane,master   2m    v1.x.x
k3d-myapp-agent-0     Ready    <none>                 2m    v1.x.x
k3d-myapp-agent-1     Ready    <none>                 2m    v1.x.x
```

If any node is `NotReady` after two minutes, run `kubectl describe node <node-name>` to see the error.

**Discussion (add to Google Doc):** k3d runs k3s nodes as Docker containers inside your team container. What resource does this create competition for? What would you check first if the cluster nodes became `NotReady` unexpectedly?

---

### Part 2: Translate Docker Compose to Kubernetes Manifests

> **Background:** kompose converts a Docker Compose file into Kubernetes YAML manifests. However, kompose generates output based on what it sees in the Compose file, carrying forward any problems present there. Two problems appear in almost every kompose output and must be fixed before the manifests are applied: plaintext environment variables and the Recreate deployment strategy.

**Step 9.** Install kompose inside the team container.

```bash
curl -L https://github.com/kubernetes/kompose/releases/latest/download/kompose-linux-amd64 -o kompose
chmod +x kompose
mv kompose /usr/local/bin/kompose
```

Verify:

```bash
kompose version
```

**Step 10.** Create a `manifests/` directory and run kompose against the Week 2 Docker Compose file.

```bash
mkdir -p manifests
cd manifests
kompose convert -f ../week-2/docker-compose.yml
```

You should see several files created: Deployments and Services for each service.

**Step 11.** Before applying anything, examine the generated Deployment for your Flask service.

```bash
cat flask-deployment.yaml
```

Find two problems:

1. **Plaintext credentials**: Look for `env:` blocks containing `POSTGRES_USER`, `POSTGRES_PASSWORD`, or `DATABASE_URL` with literal values. If present in plain text, they are visible to anyone who can read the manifest.

2. **Recreate strategy**: Look for `strategy: type: Recreate`. This takes the service offline completely before starting the new version during a rollout.

**Take a screenshot showing both issues. Add it to your team's Google Doc.**

**Discussion (add to Google Doc):** kompose translated your Compose file literally. If your Compose file had problems, they appear in the Kubernetes output unchanged. What does this tell you about treating automatically generated infrastructure code as production-ready without review?

**Step 12.** Fix Problem 1: Move plaintext credentials to a Kubernetes Secret. Create `manifests/flask-secret.yaml`.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: flask-credentials
  namespace: default
type: Opaque
stringData:
  POSTGRES_USER: appuser
  POSTGRES_PASSWORD: changeme
  DATABASE_URL: postgresql://appuser:changeme@postgres:5432/statustracker
```

> **Note:** Kubernetes Secrets are base64-encoded but not encrypted at rest by default. In production, credentials come from a secrets manager. You will improve on this in Week 7.

**Step 13.** Update the Flask Deployment to use the Secret instead of inline environment variables. Find the `env:` block in `flask-deployment.yaml` and replace it with:

```yaml
        envFrom:
          - secretRef:
              name: flask-credentials
```

Remove any inline `env:` entries that reference database credentials.

**Step 14.** Apply the same fix to the PostgreSQL Deployment: create a separate Secret and update `postgres-deployment.yaml` to use `envFrom`.

**Step 15.** Fix Problem 2: Change the deployment strategy. Open `flask-deployment.yaml` and change:

```yaml
  strategy:
    type: Recreate
```

to:

```yaml
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
```

**Discussion (add to Google Doc):** RollingUpdate replaces pods gradually, keeping the old version running until the new one is healthy. In what production scenario would you intentionally choose Recreate over RollingUpdate?

---

### Part 3: Deploy and Verify

**Step 16.** Apply the Secret manifests first.

```bash
kubectl apply -f manifests/flask-secret.yaml
kubectl apply -f manifests/postgres-secret.yaml
```

**Step 17.** Apply all remaining manifests.

```bash
kubectl apply -f manifests/
```

**Step 18.** Watch the pods come up.

```bash
kubectl get pods --watch
```

Wait until all pods show `Running`. Press `Ctrl+C` once they are stable.

**Step 19.** Test the application through the LoadBalancer.

```bash
curl http://localhost:8080/health
```

Expected: a JSON response indicating the service is up.

**Step 20.** Demonstrate a rolling update by scaling the Flask Deployment.

```bash
kubectl scale deployment flask --replicas=2
kubectl get pods --watch
```

Watch the second pod come up without the first one going down. Press `Ctrl+C` when both pods are running.

**Discussion (add to Google Doc):** If the PostgreSQL pod crashes, Kubernetes restarts it automatically. What does Kubernetes NOT recover automatically? What would a production team add to make PostgreSQL data safe?

---

### Part 4: Ansible Update

**Step 21.** Create the k3d-setup role in the Ansible directory.

```bash
mkdir -p ansible/roles/k3d-setup/tasks
```

**Step 22.** Create `ansible/roles/k3d-setup/tasks/main.yml`.

```yaml
---
- name: Check if k3d is installed
  command: which k3d
  register: k3d_check
  failed_when: false
  changed_when: false

- name: Install k3d
  shell: curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
  when: k3d_check.rc != 0

- name: Check if k3d cluster exists
  command: k3d cluster list
  register: cluster_list
  changed_when: false

- name: Create k3d cluster if not present
  command: k3d cluster create myapp --agents 2 --port "8080:80@loadbalancer"
  when: "'myapp' not in cluster_list.stdout"
```

**Step 23.** Add the k3d-setup role to `ansible/site.yml`.

```yaml
- name: Set up k3d cluster
  hosts: localhost
  connection: local
  become: yes

  roles:
    - k3d-setup
```

**Step 24.** Run the playbook to verify it executes cleanly.

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

**Step 25.** Commit all changes.

```bash
git add manifests/ ansible/
git commit -m "feat: add k8s manifests with fixed credentials and strategy; add k3d-setup role"
git push origin main
```

---

### Storage Check

```bash
df -h
docker system df
```

> **Important:** k3d creates k3s node containers using a separate containerd image store. These images are NOT visible to `docker system df`. Running `docker system prune` will not reclaim this space. This is a distinct storage pool that grows as you pull Kubernetes-managed container images.

---

### Validation Checks

#### Validation Check: k3d Cluster Is Running

```bash
k3d cluster list
```

Expected: one row showing `myapp` with STATUS `running`.

#### Validation Check: All Pods Running

```bash
kubectl get pods
```

Expected: all pods in `Running` state with `1/1` in READY.

#### Validation Check: Credentials Are in a Secret, Not a Deployment

```bash
kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].env}'
```

Expected output: empty (`[]`) or output showing only non-credential environment variables.

Also verify the Secret exists:

```bash
kubectl get secret flask-credentials
```

#### Validation Check: RollingUpdate Strategy Applied

```bash
kubectl get deployment flask -o jsonpath='{.spec.strategy.type}'
```

Expected output: `RollingUpdate`

#### Validation Check: Check Script Passes

```bash
./scripts/check-week3.sh
```

---

### Deliverables

- `manifests/` directory committed with all Kubernetes manifests (Deployments, Services, Secrets)
- Evidence of fixing plaintext env vars: Secret manifest present, Deployment uses `envFrom`
- Evidence of strategy change: `flask-deployment.yaml` shows `RollingUpdate`
- `ansible/site.yml` updated with k3d-setup play
- `ansible/roles/k3d-setup/tasks/main.yml` committed
- `./scripts/check-week3.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** kompose output showing the two issues (plaintext env vars and Recreate strategy) before fixes
- **Screenshot 2:** `kubectl get pods` showing all pods Running
- **Screenshot 3:** rolling update in progress (two Flask pods visible)
- **Screenshot 4:** `./scripts/check-week3.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. kompose generated manifests from your Compose file and both were insecure. What assumptions did kompose make that were wrong? Why doesn't a translation tool automatically correct these?
2. RollingUpdate versus Recreate: in what real-world scenario would you intentionally choose Recreate over RollingUpdate, even knowing it causes downtime?
3. Your three-tier application now has Deployments for each tier. If your PostgreSQL pod crashes, Kubernetes restarts it automatically. What does Kubernetes NOT recover automatically?
4. You moved secrets from a `.env` file to Kubernetes Secrets. Kubernetes Secrets are base64-encoded by default, not encrypted. What does this mean for your security posture, and what would a production team do differently?
5. (Extend) Your k3d cluster runs inside your team container. What happens to the cluster if the team container restarts? Is this acceptable for this class? Would it be acceptable in production?

---

### Sprint Backlog: Preparing for Week 4

Week 4 is asynchronous. Before leaving today, the Scrum Master ensures the following tickets are open:

- Install and configure OpenTofu in the team container
- Write `main.tf` with Kubernetes provider and local backend
- Define Deployments and Services as OpenTofu resources
- Run `tofu plan` and `tofu apply`
- Add k3s resilience validation steps
- Add opentofu-setup role to `ansible/site.yml`
- Update Google Doc with Week 4 reflections and storage check

---

---

## Week 4: Infrastructure as Code with OpenTofu

**Sprint 2 Async | Due before Sprint 2 Review**

### Overview

In this lab, you manage your Kubernetes infrastructure declaratively using OpenTofu, the open-source Linux Foundation-governed fork of Terraform. OpenTofu uses HCL, the same configuration language, same workflow, and the same provider ecosystem. You will write OpenTofu configuration that targets your k3d cluster through the Kubernetes provider, use a local backend to store state inside the team container, and verify that your infrastructure is idempotent and self-consistent. You will also extend the Ansible playbook with OpenTofu installation. After completing this lab, you will have your Kubernetes infrastructure defined as HCL code managed declaratively through OpenTofu.

> **OpenTofu rules enforced throughout this lab:**
> - Always say "OpenTofu" -- never "Terraform"
> - The command is `tofu`, not `terraform`
> - Link only to opentofu.org for documentation and downloads
> - Use a local backend explicitly in every configuration file

### Learning Objectives

- Install OpenTofu from opentofu.org and initialize a local backend configuration
- Write HCL resources using the Kubernetes provider to manage Deployments and Services
- Run `tofu plan` to preview changes before applying them
- Verify that `tofu apply` is idempotent (applying twice produces no additional changes)
- Extend the Ansible playbook with OpenTofu installation

### Prerequisites

- Week 3 complete: k3d cluster running with application manifests deployed
- `kubectl` is configured and cluster is reachable

---

### Part 1: Install OpenTofu and Initialize

> **Background:** OpenTofu is an open-source infrastructure-as-code tool governed by the Linux Foundation. It uses HCL (HashiCorp Configuration Language) to describe infrastructure declaratively. OpenTofu maintains full compatibility with the Terraform provider ecosystem. The command-line tool is `tofu`. Documentation and downloads are at opentofu.org.

**Step 1.** Install OpenTofu inside your team container.

```bash
curl -Lo /tmp/tofu.tar.gz \
  https://github.com/opentofu/opentofu/releases/download/v1.8.0/tofu_1.8.0_linux_amd64.tar.gz
tar -xzf /tmp/tofu.tar.gz -C /tmp
mv /tmp/tofu /usr/local/bin/tofu
chmod +x /usr/local/bin/tofu
rm /tmp/tofu.tar.gz
```

Verify:

```bash
tofu version
```

Expected: output beginning with `OpenTofu v1.x.x`.

**Step 2.** Create the OpenTofu directory in your repository.

```bash
mkdir -p infrastructure
```

**Step 3.** Create `infrastructure/main.tf`. This file defines the required providers and the backend. The local backend stores the state file on disk. This must be explicit.

```hcl
terraform {
  required_version = ">= 1.0"

  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    kubernetes = {
      source  = "opentofu/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
```

> **Note on the `terraform {}` block name:** OpenTofu uses `terraform {}` as the settings block name for backwards compatibility with the provider ecosystem. The tool, command, and project are OpenTofu. The block name is a technical compatibility detail, not a vendor reference.

**Step 4.** Initialize the OpenTofu working directory.

```bash
cd infrastructure
tofu init
```

Expected: output ending with `OpenTofu has been successfully initialized!`

**Step 5.** Add `infrastructure/terraform.tfstate` to `.gitignore`. State files can contain resource metadata that should not be in version control, even when they contain no credentials. In production, state lives in a remote backend with access controls.

```bash
echo "infrastructure/terraform.tfstate" >> .gitignore
echo "infrastructure/terraform.tfstate.backup" >> .gitignore
git add .gitignore
git commit -m "chore: ignore OpenTofu state files"
git push
```

**Discussion (add to Google Doc):** What is a provider in OpenTofu? How does the Kubernetes provider differ from, for example, an AWS provider? What does "provider" mean in the context of infrastructure as code?

---

### Part 2: Define Kubernetes Resources with OpenTofu

**Step 6.** Create `infrastructure/flask.tf`. This file defines a Kubernetes Deployment and Service for the Flask application.

```hcl
resource "kubernetes_deployment" "flask" {
  metadata {
    name      = "flask"
    namespace = "default"
    labels = {
      app = "flask"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "flask"
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }

    template {
      metadata {
        labels = {
          app = "flask"
        }
      }

      spec {
        container {
          name  = "flask"
          image = "ghcr.io/<your-org>/flask-app:latest"

          env_from {
            secret_ref {
              name = "flask-credentials"
            }
          }

          port {
            container_port = 5000
          }

          resources {
            limits = {
              cpu    = "500m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask" {
  metadata {
    name      = "flask"
    namespace = "default"
  }

  spec {
    selector = {
      app = "flask"
    }

    port {
      port        = 80
      target_port = 5000
    }
  }
}
```

Replace `<your-org>` with your team's GitHub organization or username.

**Step 7.** Run `tofu plan` to preview what would be created or modified.

```bash
tofu plan
```

Read the output carefully. It shows additions (`+`), modifications (`~`), and deletions (`-`). **Take a screenshot of the plan output and add it to your team's Google Doc.**

**Discussion (add to Google Doc):** `tofu plan` showed you what WOULD change before you changed it. How does this differ from running `kubectl apply`? What is the advantage of seeing a plan in a team environment before applying changes?

**Step 8.** Apply the configuration.

```bash
tofu apply
```

Type `yes` when prompted. Watch the output as resources are created or updated.

**Step 9.** Verify the Deployment is healthy.

```bash
kubectl get deployment flask
```

Expected: `flask` deployment with `2/2` READY.

---

### Part 3: Make a Change and Verify Idempotency

**Step 10.** Change the Flask Deployment replica count from 2 to 3 in `infrastructure/flask.tf`.

**Step 11.** Preview the change.

```bash
tofu plan
```

You should see a modification (`~`) to the Flask Deployment affecting `replicas` only.

**Step 12.** Apply the change.

```bash
tofu apply
```

**Step 13.** Verify the replica count updated.

```bash
kubectl get deployment flask
```

Expected: `3/3` READY.

**Step 14.** Run `tofu apply` again without making any changes.

```bash
tofu apply
```

Expected output ends with: `Apply complete! Resources: 0 added, 0 changed, 0 destroyed.`

This confirms the configuration is idempotent.

> **Enterprise Pattern:** Idempotency means that applying the same configuration multiple times produces the same result. This is a fundamental requirement for infrastructure-as-code tooling used in automated pipelines: if running the same configuration twice causes changes, the tool cannot be safely automated.

**Discussion (add to Google Doc):** `tofu apply` ran a second time and made no changes. What does this tell you about how OpenTofu tracks state? Where is that state stored, and what happens if the state file is lost or corrupted?

---

### Part 4: k3s Resilience Validation

**Step 15.** Get the name of one of the Flask pods.

```bash
kubectl get pods -l app=flask
```

Copy one pod name from the output.

**Step 16.** Delete that pod manually.

```bash
kubectl delete pod <pod-name>
```

**Step 17.** Watch what happens.

```bash
kubectl get pods -l app=flask --watch
```

You should see the deleted pod enter `Terminating` and a new pod appear in `ContainerCreating` almost immediately. Within 30-60 seconds, all three pods should be running again. **Take a screenshot showing the pod cycling.**

**Step 18.** Run `tofu plan` after the pod recovery.

```bash
tofu plan
```

Expected: `No changes. Your infrastructure matches the configuration.`

**Discussion (add to Google Doc):** Kubernetes automatically replaced the deleted pod. What is the boundary of what Kubernetes can recover from automatically? Give one example of a failure that Kubernetes cannot recover from without human intervention.

---

### Part 5: Ansible Update

**Step 19.** Create the opentofu-setup role.

```bash
mkdir -p ansible/roles/opentofu-setup/tasks
```

**Step 20.** Create `ansible/roles/opentofu-setup/tasks/main.yml`.

```yaml
---
- name: Check if OpenTofu is installed
  command: which tofu
  register: tofu_check
  failed_when: false
  changed_when: false

- name: Download and install OpenTofu
  block:
    - name: Download OpenTofu tarball
      get_url:
        url: https://github.com/opentofu/opentofu/releases/download/v1.8.0/tofu_1.8.0_linux_amd64.tar.gz
        dest: /tmp/tofu.tar.gz
        mode: '0644'

    - name: Extract OpenTofu binary
      unarchive:
        src: /tmp/tofu.tar.gz
        dest: /usr/local/bin
        remote_src: yes
        extra_opts: ['--wildcards', 'tofu']

    - name: Ensure tofu is executable
      file:
        path: /usr/local/bin/tofu
        mode: '0755'

    - name: Remove tarball
      file:
        path: /tmp/tofu.tar.gz
        state: absent
  when: tofu_check.rc != 0

- name: Initialize OpenTofu working directory
  command: tofu init
  args:
    chdir: "{{ playbook_dir }}/../infrastructure"
  changed_when: false
```

**Step 21.** Add the opentofu-setup role to `ansible/site.yml`.

```yaml
- name: Install and initialize OpenTofu
  hosts: localhost
  connection: local
  become: yes

  roles:
    - opentofu-setup
```

**Step 22.** Run the playbook and confirm it passes.

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

**Step 23.** Commit everything.

```bash
git add infrastructure/ ansible/
git commit -m "feat: add OpenTofu configuration for k8s resources; add opentofu-setup Ansible role"
git push origin main
```

---

### Storage Check

```bash
df -h
docker system df
```

> **Note:** The state file (`infrastructure/terraform.tfstate`) contains the current state of all managed resources and is intentionally excluded from version control. In production, state lives in a remote backend with state locking to prevent two operators from applying simultaneously. If two team members run `tofu apply` simultaneously against the same cluster, the second will read stale state. If this happens, run `tofu refresh` to re-read actual cluster state before running `tofu plan` again.

---

### Validation Checks

#### Validation Check: OpenTofu Applies Without Error

```bash
tofu plan
```

Expected: `No changes. Your infrastructure matches the configuration.`

#### Validation Check: Flask Deployment Has 3 Replicas

```bash
kubectl get deployment flask -o jsonpath='{.spec.replicas}'
```

Expected output: `3`

#### Validation Check: infrastructure/main.tf Has Local Backend

```bash
grep -A3 "backend" infrastructure/main.tf
```

Expected: output showing `backend "local" { path = "terraform.tfstate" }`.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week4.sh
```

---

### Deliverables

- `infrastructure/main.tf` committed (with explicit local backend and Kubernetes provider)
- `infrastructure/flask.tf` committed (Deployment and Service)
- `.gitignore` updated to exclude state files
- Screenshot of `tofu plan` output showing planned changes from Part 3
- `ansible/site.yml` updated with opentofu-setup play
- `ansible/roles/opentofu-setup/tasks/main.yml` committed
- `./scripts/check-week4.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** `tofu plan` output from Part 2
- **Screenshot 2:** pod cycling during resilience test
- **Screenshot 3:** `tofu plan` showing `No changes` after second apply
- **Screenshot 4:** `./scripts/check-week4.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. You wrote HCL configuration that describes what your Kubernetes cluster should look like. If you deleted the cluster and re-ran `tofu apply`, would it recreate everything? What would NOT be recreated automatically?
2. Your state file lives in `infrastructure/terraform.tfstate`. If two team members both run `tofu apply` simultaneously against the same cluster, what happens? How do production teams solve this?
3. You managed Kubernetes resources with OpenTofu instead of `kubectl`. What is the tradeoff? When would a team choose `kubectl` directly over an IaC tool?
4. The Kubernetes provider for OpenTofu reads your kubeconfig, which points at a local k3d cluster. What would you need to change if you wanted to target a cloud-hosted Kubernetes cluster instead?
5. (Extend) Your local backend stores state on disk in the team container. What happens to your state file if the container is wiped? What would need to change about your OpenTofu setup to survive a container wipe?

---

## Week 5: Observability and Monitoring

**Sprint 3 Kickoff | Synchronous**

### Overview

In this lab, you deploy the kube-prometheus-stack using Helm into your k3d cluster, configure Prometheus to scrape container metrics from cAdvisor and kubelet, and build Grafana dashboards that surface the USE method (Utilization, Saturation, Errors) for your application stack. After completing this lab, you will have a working observability stack producing real metrics from your application, with Prometheus confirmed to scrape the specific metric (`container_cpu_cfs_throttled_seconds_total`) that Week 9 depends on for CPU throttling diagnosis.

> **Cross-week dependency (mandatory):** This lab has a specific metric verification step that must pass before Week 9 can work. Do not skip Validation Check 3.

### Learning Objectives

- Deploy kube-prometheus-stack using Helm into a Kubernetes namespace
- Verify Prometheus is scraping cAdvisor and kubelet metrics (not just node_exporter)
- Build Grafana dashboards using the USE method for CPU, memory, and network
- Configure a Grafana alert on error rate
- Interpret metric output to distinguish utilization from saturation

### Prerequisites

- Week 4 complete: k3d cluster running, application deployed, OpenTofu managing Kubernetes resources
- `helm` available in the container (installed in this lab)

### Sprint Review: Sprint 2

**Step 1.** Open the sprint board. Move all Sprint 2 items to Done. For incomplete items, add a one-line note on what remains.

**Step 2.** Sprint retrospective (whole group, record in Google Doc under "Sprint 2 Close"):
- What worked well this sprint?
- What slowed the team down?
- What one practice change would you make in Sprint 3?

**Step 3.** Environment checkpoint.

```bash
k3d cluster list
kubectl get nodes
kubectl get pods
git log --oneline -5
```

Paste output into Google Doc under "Sprint 3 Kickoff -- Environment State."

**Step 4.** Assign Sprint 3 roles and open Sprint 3 issues on the board.

---

### Part 1: Install Helm and Deploy kube-prometheus-stack

> **Background:** kube-prometheus-stack is a Helm chart that bundles Prometheus, Grafana, Alertmanager, and a set of pre-built dashboards into a single deployable package. Helm is a package manager for Kubernetes that templates and packages Kubernetes manifests so they can be installed with a single command.

**Step 1.** Install Helm inside the team container.

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify:

```bash
helm version
```

Expected: output beginning with `version.BuildInfo{Version:"v3.x.x"`.

**Step 2.** Add the Prometheus community Helm chart repository.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Expected: `Update Complete. Happy Helming!`

**Step 3.** Create a namespace for the monitoring stack.

```bash
kubectl create namespace monitoring
```

**Step 4.** Create `week-5/prometheus-values.yaml`. This configuration enables cAdvisor and kubelet scraping explicitly. This is what makes Week 9's CPU throttling diagnosis work.

```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false

kubelet:
  enabled: true
  serviceMonitor:
    https: true

grafana:
  adminPassword: "changethis"
  service:
    type: NodePort
    nodePort: 30080

alertmanager:
  enabled: true
```

**Step 5.** Deploy the kube-prometheus-stack.

```bash
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f week-5/prometheus-values.yaml
```

This takes two to three minutes.

**Step 6.** Watch the pods come up.

```bash
kubectl get pods -n monitoring --watch
```

Wait until all pods show `Running` or `Completed`. Press `Ctrl+C` when stable.

---

### Part 2: Verify cAdvisor/kubelet Metrics Are Available

> **This step is mandatory.** Week 9's CPU throttling diagnosis queries `rate(container_cpu_cfs_throttled_seconds_total[5m])`. If Prometheus is not scraping kubelet metrics, this query returns no data and Week 9 fails. Complete this verification before moving on.

**Step 7.** Port-forward Prometheus to your local port.

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090 &
```

**Step 8.** Query Prometheus for the throttling metric.

```bash
curl -s 'http://localhost:9090/api/v1/query?query=container_cpu_cfs_throttled_seconds_total' \
  | python3 -c "import json,sys; d=json.load(sys.stdin); r=d['data']['result']; print(f'PASS -- {len(r)} series found') if r else print('FAIL -- no data returned')"
```

Expected: `PASS -- N series found` where N is greater than zero.

If you see `FAIL`: Prometheus is not scraping kubelet. The most common cause is that the kubelet ServiceMonitor was not created. Verify:

```bash
kubectl get servicemonitor -n monitoring
```

You should see a row for `kube-prometheus-stack-kubelet`. If it is missing, run:

```bash
helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f week-5/prometheus-values.yaml
```

Wait two minutes and re-run Step 8.

**Screenshot required:** Add a screenshot showing the Prometheus query returning data for `container_cpu_cfs_throttled_seconds_total` to your Google Doc. Label it "Week 5 -- Week 9 Dependency Verified."

**Step 9.** Stop the port-forward.

```bash
kill %1
```

---

### Part 3: Grafana Dashboards and the USE Method

> **Background:** The USE method (Utilization, Saturation, Errors) is a structured approach to performance diagnosis. For every resource: check utilization (how busy is it?), saturation (is work queuing?), and errors (are there failures?). This prevents teams from chasing symptoms before diagnosing root cause.

**Step 10.** Port-forward Grafana.

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 &
```

**Step 11.** Open Grafana in a browser at `http://localhost:3000`. Log in with username `admin` and the password from your values file.

**Step 12.** Navigate to Dashboards. Find and open the "Kubernetes / Compute Resources / Pod" dashboard. Explore the pre-built panels.

**Discussion (add to Google Doc):** Find a panel in the pre-built dashboard that represents each USE signal. Which panel shows CPU utilization? Which shows memory saturation? What does "errors" mean for a container metric?

**Step 13.** Build a custom USE dashboard for the Flask service. Navigate to Dashboards > New > Add visualization.

Add three panels:

**Panel 1 -- CPU Utilization:**
```
rate(container_cpu_usage_seconds_total{container="flask"}[5m])
```
Title: `Flask CPU Utilization`

**Panel 2 -- CPU Saturation (throttling):**
```
rate(container_cpu_cfs_throttled_seconds_total{container="flask"}[5m])
```
Title: `Flask CPU Throttle Rate`

**Panel 3 -- HTTP Error Rate:**
```
sum(rate(nginx_http_requests_total{status=~"5.."}[5m])) / sum(rate(nginx_http_requests_total[5m]))
```
Title: `HTTP 5xx Error Rate`

Save the dashboard as "Flask USE Dashboard."

**Step 14.** Configure a Grafana alert on the HTTP error rate panel. Set the alert to fire when the error rate exceeds 1% for one minute.

---

### Part 4: Generate Load and Observe

**Step 15.** Install k6 inside the team container.

```bash
curl https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz -Lo /tmp/k6.tar.gz
tar -xzf /tmp/k6.tar.gz -C /tmp
mv /tmp/k6-v0.47.0-linux-amd64/k6 /usr/local/bin/k6
rm /tmp/k6.tar.gz
```

**Step 16.** Create `week-5/smoke-test.js`.

```javascript
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 5,
  duration: '1m',
};

export default function () {
  http.get('http://localhost:8080/incidents');
  sleep(1);
}
```

**Step 17.** Run the smoke test while watching Grafana.

```bash
k6 run week-5/smoke-test.js
```

Watch your Grafana Flask USE Dashboard while k6 runs. You should see activity in the CPU utilization panel.

**Step 18.** Stop the port-forward.

```bash
kill %1
```

---

### Storage Check

```bash
df -h
docker system df
kubectl top pods -n monitoring
```

Record all three outputs in your Google Doc under "Week 5 Storage Check."

---

### Validation Checks

#### Validation Check: All Monitoring Pods Running

```bash
kubectl get pods -n monitoring
```

Expected: all pods in `Running` or `Completed` state.

#### Validation Check: kubelet ServiceMonitor Exists

```bash
kubectl get servicemonitor -n monitoring | grep kubelet
```

Expected: at least one row containing `kubelet`.

#### Validation Check: container_cpu_cfs_throttled_seconds_total Returns Data (MANDATORY)

```bash
curl -s 'http://localhost:9090/api/v1/query?query=container_cpu_cfs_throttled_seconds_total' \
  | python3 -c "import json,sys; d=json.load(sys.stdin); print('PASS') if d['data']['result'] else print('FAIL')"
```

Expected output: `PASS`

If you see `FAIL`: Week 9's CPU throttling diagnosis will not work. Fix kubelet scraping before submitting.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week5.sh
```

---

### Deliverables

- `week-5/prometheus-values.yaml` committed (with kubelet scraping enabled)
- `week-5/smoke-test.js` committed
- Grafana "Flask USE Dashboard" screenshot in Google Doc
- Screenshot of `container_cpu_cfs_throttled_seconds_total` returning data from Prometheus (labeled "Week 9 Dependency Verified")
- `./scripts/check-week5.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** All monitoring pods in `Running` state
- **Screenshot 2:** Prometheus query returning data for `container_cpu_cfs_throttled_seconds_total` (MANDATORY)
- **Screenshot 3:** Flask USE Dashboard in Grafana with at least one panel showing data
- **Screenshot 4:** `./scripts/check-week5.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. The USE method asks you to examine Utilization, Saturation, and Errors for each resource. Walk through all three for your Flask container using what you saw in Grafana during the smoke test. Be specific about which metric represents each category.
2. This lab required Prometheus to scrape cAdvisor and kubelet, not just node_exporter. What does node_exporter provide that kubelet/cAdvisor does not, and vice versa?
3. Grafana shows historical metric data. What would a production team do when an alert fires at 3am on a metric they have never analyzed before? What would they look at first?
4. kube-prometheus-stack was deployed with Helm. What is the difference between `helm install` and `kubectl apply -f`? Why would a team choose Helm for this use case?
5. (Extend) Your Grafana alert fires after one minute above threshold. What are the risks of setting the alert threshold too low? Too high?

---

### Sprint Backlog: Preparing for Week 6

Week 6 is asynchronous. Before leaving, the Scrum Master ensures the following tickets are open:

- Write GitHub Actions CI pipeline for Docker build and push
- Write scheduled workflow (cron syntax)
- Configure branch protection with CI as required check
- Trigger a deliberate CI failure and observe merge block
- Update Google Doc with Week 6 reflections and storage check

---

---

## Week 6: GitHub Actions and CI/CD

**Sprint 3 Async | Due before Sprint 3 Review**

### Overview

In this lab, your team builds two GitHub Actions workflows: a CI pipeline that builds and pushes your Flask Docker image on every pull request, and a scheduled maintenance workflow that runs weekly. You will configure workflow secrets, enforce a branch protection rule that requires CI to pass before merging, and observe how a failing pipeline blocks a merge. After completing this lab, you will have a working CI/CD pipeline committed to your repository that validates every code change automatically and a scheduled workflow running on a defined cron schedule.

> **Scheduling note:** This lab uses GitHub Actions cron syntax for scheduling, not systemd timers. Systemd timer behavior inside nested Docker containers is unreliable. GitHub Actions runs on GitHub's infrastructure outside the container, making it the correct tool for scheduled workflows in this environment.

### Learning Objectives

- Write a GitHub Actions workflow for Docker build and image push
- Configure workflow secrets for credentials without hardcoding them in YAML
- Enforce branch protection so CI must pass before a PR can merge
- Write a scheduled workflow using cron syntax
- Trigger a pipeline failure deliberately and observe the merge block

### Prerequisites

- Week 5 complete: monitoring stack deployed
- GitHub repository with Write access for all team members
- Access to GitHub Container Registry (ghcr.io)

---

### Part 1: CI Pipeline for Docker Build and Push

**Step 1.** Create the GitHub Actions workflow directory inside your repo.

```bash
mkdir -p .github/workflows
```

**Step 2.** Create `.github/workflows/ci.yml`.

```yaml
name: CI -- Build and Push Docker Image

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}/flask-app

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata for Docker
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=sha-
            type=ref,event=branch
            type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: ./week-2/app
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

> **Note on authentication:** This workflow uses `GITHUB_TOKEN`, automatically provided by GitHub Actions. No team member needs to create or store a personal access token for pushes to ghcr.io. `GITHUB_TOKEN` is scoped to the current repository and expires when the workflow finishes.

**Step 3.** Commit and push the workflow.

```bash
git add .github/
git commit -m "feat: add CI workflow for Docker build and push"
git push origin main
```

**Step 4.** Navigate to the Actions tab on your GitHub repository. Wait for the workflow run triggered by your push to complete. If it fails, check the error output and fix.

**Discussion (add to Google Doc):** The workflow triggers on both push to main and on pull requests. What is the difference between these two triggers in terms of when your team gets feedback?

---

### Part 2: Workflow Secrets and Branch Protection

**Step 5.** Navigate to Settings > Secrets and variables > Actions > New repository secret. Create a secret named `SLACK_WEBHOOK_URL` with a placeholder value (for use in Part 3).

> **Enterprise Pattern:** Workflow secrets are injected at runtime by GitHub. They are never printed in logs, inaccessible to forked repositories by default, and encrypted at rest.

**Step 6.** Configure branch protection for `main`. Navigate to Settings > Branches > Add rule.

- Branch name pattern: `main`
- Enable: "Require a pull request before merging"
- Enable: "Require status checks to pass before merging"
- Add the `build-and-push` status check
- Enable: "Require branches to be up to date before merging"
- Save the rule.

**Step 7.** Create a new branch and introduce a build failure.

```bash
git checkout -b test/failing-build
```

Open `week-2/app/Dockerfile` and change `FROM python:3.11-slim` to `FRMM python:3.11-slim` (intentional syntax error).

```bash
git add week-2/app/Dockerfile
git commit -m "test: intentional build failure to verify branch protection"
git push origin test/failing-build
```

**Step 8.** Open a pull request from `test/failing-build` to `main` on GitHub. Wait for CI to run. Observe that the merge button is disabled and blocked after the build fails.

**Take a screenshot** of the pull request showing the blocked merge and failed check. Add it to your Google Doc.

**Step 9.** Fix the Dockerfile, push the fix, and watch CI re-run.

```bash
git add week-2/app/Dockerfile
git commit -m "fix: restore valid Dockerfile FROM instruction"
git push origin test/failing-build
```

After CI passes, merge the PR on GitHub. Delete the test branch.

---

### Part 3: Scheduled Maintenance Workflow

**Step 10.** Create `.github/workflows/scheduled-maintenance.yml`.

```yaml
name: Scheduled Maintenance

on:
  schedule:
    - cron: '0 8 * * 1'
  workflow_dispatch:

jobs:
  weekly-report:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Report workflow run
        run: |
          echo "Weekly maintenance completed at $(date -u)"
          echo "Repository: ${{ github.repository }}"
          echo "Triggered by: ${{ github.event_name }}"

      - name: Scan image for critical vulnerabilities
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'ghcr.io/${{ github.repository }}/flask-app:latest'
          format: 'table'
          exit-code: '0'
          severity: 'CRITICAL'
```

> **Cron syntax:** `0 8 * * 1` means "08:00 UTC every Monday." Five fields: minute, hour, day of month, month, day of week (1 = Monday).

**Step 11.** Trigger the workflow manually from the Actions tab.

**Step 12.** Commit the scheduled workflow.

```bash
git add .github/
git commit -m "feat: add weekly scheduled maintenance workflow"
git push origin main
```

---

### Storage Check

```bash
df -h
docker system df
```

Record in your Google Doc under "Week 6 Storage Check."

---

### Validation Checks

#### Validation Check: CI Workflow Passes on main

Navigate to Actions tab. The most recent run on `main` shows a green checkmark.

#### Validation Check: Branch Protection Configured

Navigate to Settings > Branches. Confirm the `main` rule requires status checks.

#### Validation Check: Scheduled Workflow Runs Successfully

In the Actions tab, confirm the Scheduled Maintenance workflow completed without error when manually triggered.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week6.sh
```

---

### Deliverables

- `.github/workflows/ci.yml` committed (build and push, manual trigger)
- `.github/workflows/scheduled-maintenance.yml` committed
- Branch protection rule configured on `main`
- Screenshot of failed CI blocking a merge
- Screenshot of passing CI after fix
- `./scripts/check-week6.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** PR blocked from merging with failing CI check
- **Screenshot 2:** PR unblocked after CI passes
- **Screenshot 3:** Scheduled Maintenance workflow run success
- **Screenshot 4:** `./scripts/check-week6.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. Your CI runs on both push to main and on PRs. What would happen to your team's workflow if CI only ran on pushes to main? What is the cost of finding a broken build after merge?
2. The scheduled workflow uses cron syntax. Why did this lab choose GitHub Actions instead of a systemd timer inside the container?
3. Secrets stored in GitHub are never printed in logs. Is this foolproof? What would a security-conscious team do in addition to relying on GitHub's secret masking?
4. Branch protection required CI to pass before merging. Name one case where a team might bypass branch protection, and describe what governance controls a larger organization would put in place.
5. (Extend) Your CI pipeline builds a Docker image but does not run automated tests on the application code. What would you add to make CI provide stronger guarantees before a push to main?

---

---

## Week 7: Security Hardening and Shift Left

**Sprint 4 Kickoff | Synchronous**

### Overview

In this lab, you apply Kubernetes security controls to your deployed application: RBAC (Role-Based Access Control), NetworkPolicy to restrict pod-to-pod traffic, and SecurityContext to prevent privilege escalation inside containers. You will also add an automated image vulnerability scan to the CI pipeline, making security a gate on every build. After completing this lab, you will have a hardened application deployment with RBAC, NetworkPolicy, SecurityContext, and automated vulnerability scanning all committed to your repository.

### Learning Objectives

- Configure Kubernetes RBAC with a least-privilege ServiceAccount, Role, and RoleBinding
- Apply a NetworkPolicy that restricts pod-to-pod communication to declared paths only
- Configure SecurityContext settings to prevent privilege escalation inside containers
- Add automated image scanning to the GitHub Actions pipeline as a required check
- Understand the difference between authentication and authorization in Kubernetes

### Prerequisites

- Week 6 complete: GitHub Actions CI pipeline passing, branch protection configured
- k3d cluster running with application deployed

### Sprint Review: Sprint 3

**Step 1.** Open the sprint board. Move all Sprint 3 items to Done.

**Step 2.** Retrospective in Google Doc under "Sprint 3 Close": What was the most technically challenging part? Which role was most stressful? What one concrete change will the team make in Sprint 4?

**Step 3.** Environment checkpoint.

```bash
k3d cluster list
kubectl get pods
kubectl get pods -n monitoring
git log --oneline -5
```

Paste into Google Doc under "Sprint 4 Kickoff -- Environment State."

**Step 4.** Assign Sprint 4 roles and open Sprint 4 issues.

---

### Part 1: Kubernetes RBAC

> **Background:** By default, pods run using the `default` ServiceAccount, which has broad permissions. RBAC restricts what actions identities can take on Kubernetes resources. Least privilege means granting only the permissions required for a specific purpose.

**Step 1.** Create `manifests/flask-serviceaccount.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: flask-app
  namespace: default
automountServiceAccountToken: false
```

`automountServiceAccountToken: false` prevents the Kubernetes API token from being automatically mounted inside the container. The Flask app does not call the Kubernetes API, so this token is unnecessary exposure.

**Step 2.** Create `manifests/flask-role.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: flask-reader
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list"]
```

**Step 3.** Create `manifests/flask-rolebinding.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: flask-reader-binding
  namespace: default
subjects:
  - kind: ServiceAccount
    name: flask-app
    namespace: default
roleRef:
  kind: Role
  name: flask-reader
  apiGroup: rbac.authorization.k8s.io
```

**Step 4.** Update the Flask Deployment to use the new ServiceAccount. Add `serviceAccountName: flask-app` under `spec.template.spec` in `manifests/flask-deployment.yaml`.

**Step 5.** Apply the new manifests.

```bash
kubectl apply -f manifests/flask-serviceaccount.yaml
kubectl apply -f manifests/flask-role.yaml
kubectl apply -f manifests/flask-rolebinding.yaml
kubectl apply -f manifests/flask-deployment.yaml
```

**Discussion (add to Google Doc):** RBAC separates authentication (who are you?) from authorization (what can you do?). Your Flask pod now has a custom ServiceAccount. Does having a custom ServiceAccount mean the pod can do more or less in the cluster than before? What specifically changed?

---

### Part 2: NetworkPolicy

> **Background:** By default, all pods can communicate with all other pods in Kubernetes. A NetworkPolicy restricts which pods can send and receive traffic. Without it, a compromised pod can reach any other pod in the cluster.

**Step 6.** Create `manifests/default-deny.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: default
spec:
  podSelector: {}
  policyTypes:
    - Ingress
```

**Step 7.** Apply the deny policy.

```bash
kubectl apply -f manifests/default-deny.yaml
```

**Step 8.** Test that the deny policy blocks traffic. Attempt to reach Flask from a debug pod.

```bash
kubectl run test-pod --image=curlimages/curl:latest --restart=Never --rm -it -- curl --max-time 5 http://flask/health
```

Expected result: the connection times out. **Take a screenshot of the timeout.**

**Step 9.** Create `manifests/allow-nginx-to-flask.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-nginx-to-flask
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: flask
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: nginx
      ports:
        - protocol: TCP
          port: 5000
```

Create `manifests/allow-flask-to-postgres.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-flask-to-postgres
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: postgres
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: flask
      ports:
        - protocol: TCP
          port: 5432
```

**Step 10.** Apply the allow policies.

```bash
kubectl apply -f manifests/allow-nginx-to-flask.yaml
kubectl apply -f manifests/allow-flask-to-postgres.yaml
```

**Step 11.** Verify the application still works end to end.

```bash
curl http://localhost:8080/incidents
```

Expected: valid JSON response.

**Discussion (add to Google Doc):** If a real attacker compromised your Nginx container, what traffic paths would they have available after your NetworkPolicies are applied? What paths remain that you might want to restrict further?

---

### Part 3: SecurityContext

**Step 12.** Add SecurityContext settings to the Flask Deployment. Open `manifests/flask-deployment.yaml` and add under the container spec:

```yaml
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          capabilities:
            drop:
              - ALL
```

**Step 13.** Apply the updated deployment.

```bash
kubectl apply -f manifests/flask-deployment.yaml
```

**Step 14.** Verify the pods restart and come back healthy.

```bash
kubectl get pods -l app=flask --watch
```

If pods fail to start, check:

```bash
kubectl describe pod <flask-pod-name>
```

A common failure: the Flask app writes to a path that is now read-only. If this happens, add a writable `emptyDir` volume for that specific path.

> **Enterprise Pattern:** Settings like `allowPrivilegeEscalation: false` and `readOnlyRootFilesystem: true` are required by common production security baselines (CIS Kubernetes Benchmark, NSA hardening guide). Dropping all Linux capabilities removes ambient privileges that many container exploits depend on.

---

### Part 4: Image Vulnerability Scanning in CI

**Step 15.** Update `.github/workflows/ci.yml` to add a Trivy scan job after the build.

```yaml
  security-scan:
    runs-on: ubuntu-latest
    needs: build-and-push
    if: github.event_name != 'pull_request'

    steps:
      - name: Run Trivy vulnerability scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'ghcr.io/${{ github.repository }}/flask-app:latest'
          format: 'table'
          exit-code: '1'
          severity: 'CRITICAL'
```

**Step 16.** Commit all changes.

```bash
git add .github/workflows/ci.yml manifests/
git commit -m "feat: add RBAC, NetworkPolicy, SecurityContext, and Trivy scan to CI"
git push origin main
```

---

### Validation Checks

#### Validation Check: Flask Uses Custom ServiceAccount

```bash
kubectl get pod -l app=flask -o jsonpath='{.items[0].spec.serviceAccountName}'
```

Expected output: `flask-app`

#### Validation Check: NetworkPolicy Applied

```bash
kubectl get networkpolicy
```

Expected: rows for `default-deny-ingress`, `allow-nginx-to-flask`, `allow-flask-to-postgres`.

#### Validation Check: Application Works After NetworkPolicy

```bash
curl -s http://localhost:8080/incidents
```

Expected: valid JSON.

#### Validation Check: SecurityContext Is Set

```bash
kubectl get deployment flask -o jsonpath='{.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation}'
```

Expected output: `false`

#### Validation Check: Check Script Passes

```bash
./scripts/check-week7.sh
```

---

### Deliverables

- `manifests/flask-serviceaccount.yaml`, `flask-role.yaml`, `flask-rolebinding.yaml` committed
- `manifests/default-deny.yaml`, `allow-nginx-to-flask.yaml`, `allow-flask-to-postgres.yaml` committed
- `manifests/flask-deployment.yaml` updated with SecurityContext
- `.github/workflows/ci.yml` updated with Trivy scan job
- `./scripts/check-week7.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** Connection timeout from test pod after default-deny policy applied
- **Screenshot 2:** Application responding successfully after allow policies applied
- **Screenshot 3:** Trivy scan result in GitHub Actions
- **Screenshot 4:** `./scripts/check-week7.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. You created a ServiceAccount with no Kubernetes API permissions and disabled automatic token mounting. What attack surface does this reduce compared to the default ServiceAccount behavior?
2. After applying the allow policies, list each communication path that is now permitted (source, destination, port). Which paths remain unrestricted?
3. `readOnlyRootFilesystem: true` prevents the Flask container from writing to most of its filesystem. Why is this a security improvement? What operational problem does it introduce, and how did you resolve it?
4. The Trivy scan runs after the image is built and pushed. In a stricter security model, where else in the pipeline might you add scanning? What is the tradeoff of scanning earlier versus later?
5. (Extend) Kubernetes NetworkPolicy is enforced by the CNI plugin. If the CNI plugin is not NetworkPolicy-aware, the NetworkPolicy objects exist in etcd but have no enforcement effect. How would you verify that your k3d cluster is actually enforcing NetworkPolicies?

---

### Sprint Backlog: Preparing for Week 8

Week 8 is asynchronous. Before leaving, the Scrum Master ensures the following tickets are open:

- Provision MinIO container as backup target
- Configure restic to back up PostgreSQL data volume to MinIO
- Set up GitHub Actions scheduled backup workflow
- Simulate data loss and execute recovery drill
- Write Week 8 runbook
- Update Google Doc with Week 8 reflections and storage check

---

---

## Week 8: Data Observability and Backup Verification

**Sprint 4 Async | Due before Sprint 4 Review**

### Overview

In this lab, your team builds an automated backup pipeline for your PostgreSQL database, verifies that backups actually work under a simulated failure, and measures your recovery time against a defined target. You will provision a MinIO container as an S3-compatible backup destination, automate backups with restic using a GitHub Actions scheduled workflow, apply a retention policy, and simulate real data loss with a recovery drill. After completing this lab, you will have a working backup pipeline with a verified recovery procedure and a runbook documenting both.

### Learning Objectives

- Provision MinIO as an S3-compatible backup target using a Docker container
- Configure restic for PostgreSQL data volume backups to an S3-compatible backend
- Implement a retention policy using `restic forget --prune`
- Automate backups using a GitHub Actions scheduled workflow with cron syntax
- Execute a recovery drill and measure actual RTO against a stated target

### Prerequisites

- Week 7 complete: security controls applied, CI pipeline passing
- Application is running with data in the database

---

### Part 1: Provision MinIO

> **Background:** MinIO is an open-source, S3-compatible object storage server. Running it as a Docker container gives you an S3 endpoint without cloud credentials. restic works identically whether the target is AWS S3 or a local MinIO instance.

**Step 1.** Create the directory for this week's files.

```bash
mkdir -p week-8
```

**Step 2.** Generate a MinIO password and save it to a credentials file.

```bash
export MINIO_ROOT_PASSWORD="$(openssl rand -base64 24)"
echo "MINIO_ROOT_USER=backup" >> week-8/.env.backup
echo "MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}" >> week-8/.env.backup
```

Add `week-8/.env.backup` to `.gitignore`.

**Step 3.** Start MinIO.

```bash
docker run -d --name minio \
  -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=backup \
  -e MINIO_ROOT_PASSWORD="${MINIO_ROOT_PASSWORD}" \
  -v minio-data:/data \
  minio/minio server /data --console-address ":9001"
```

**Step 4.** Verify MinIO is running.

```bash
docker ps --filter name=minio
```

Expected: MinIO container with `Up` status.

**Step 5.** Create a backup bucket.

```bash
docker run --rm --network host minio/mc:latest alias set local http://localhost:9000 backup "${MINIO_ROOT_PASSWORD}"
docker run --rm --network host minio/mc:latest mb local/backups
```

**Discussion (add to Google Doc):** MinIO provides an S3-compatible API. If you later wanted to move backups to AWS S3, what would change in your restic configuration? What would NOT change?

---

### Part 2: Configure restic Backups

**Step 6.** Install restic.

```bash
apt-get install -y restic
```

**Step 7.** Create `week-8/restic-env.sh`. Source this file before running any restic commands.

```bash
export RESTIC_REPOSITORY="s3:http://localhost:9000/backups"
export AWS_ACCESS_KEY_ID=backup
export AWS_SECRET_ACCESS_KEY="${MINIO_ROOT_PASSWORD}"
export RESTIC_PASSWORD="changethispassword"
```

Replace `changethispassword` with a strong password your team generates and records somewhere safe. If this value is lost, your backups cannot be decrypted.

**Step 8.** Initialize the restic repository.

```bash
source week-8/restic-env.sh
restic init
```

Expected: `created restic repository <id> at s3:http://localhost:9000/backups`

**Step 9.** Take a test backup.

```bash
source week-8/restic-env.sh
restic backup /var/lib/docker/volumes/week-2_db-data/_data --tag postgres --tag manual
```

**Step 10.** Verify the backup exists.

```bash
source week-8/restic-env.sh
restic snapshots
```

Expected: a table showing one snapshot with timestamp, tags, and path.

**Step 11.** Apply a retention policy.

```bash
source week-8/restic-env.sh
restic forget --prune \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 3
```

**Discussion (add to Google Doc):** The retention policy keeps 7 daily, 4 weekly, and 3 monthly snapshots. If a corruption went undetected for 10 days, could you recover clean data?

---

### Part 3: Automated Backups via GitHub Actions

**Step 12.** Add restic credentials as GitHub Actions secrets (Settings > Secrets > Actions):

- `RESTIC_REPOSITORY`
- `RESTIC_PASSWORD`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Step 13.** Create `.github/workflows/backup.yml`.

```yaml
name: Scheduled Database Backup

on:
  schedule:
    - cron: '0 2 * * *'
  workflow_dispatch:

jobs:
  backup:
    runs-on: ubuntu-latest

    steps:
      - name: Install restic
        run: sudo apt-get install -y restic

      - name: Verify repository and prune old snapshots
        env:
          RESTIC_REPOSITORY: ${{ secrets.RESTIC_REPOSITORY }}
          RESTIC_PASSWORD: ${{ secrets.RESTIC_PASSWORD }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          restic snapshots
          restic forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 3
```

**Step 14.** Trigger the backup workflow manually from the Actions tab.

---

### Part 4: Recovery Drill

**Step 15.** Record the row count before the drill.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
```

Record in Google Doc under "Week 8 Recovery Drill."

**Step 16.** Take a fresh pre-drill backup.

```bash
source week-8/restic-env.sh
restic backup /var/lib/docker/volumes/week-2_db-data/_data --tag postgres --tag pre-drill
```

**Step 17.** Start a timer. Drop the incidents table.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "DROP TABLE incidents;"
```

**Step 18.** Verify the data is gone.

```bash
curl http://localhost:8080/incidents
```

Expected: an error response.

**Step 19.** Stop application components to avoid writes during restore.

```bash
docker compose -f week-2/docker-compose.yml stop flask nginx
```

**Step 20.** Restore the backup.

```bash
source week-8/restic-env.sh
restic restore latest --target /tmp/restore --include /var/lib/docker/volumes/week-2_db-data/_data
```

**Step 21.** Restart the application.

```bash
docker compose -f week-2/docker-compose.yml up -d
```

**Step 22.** Verify the data is restored.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
```

Row count should match the pre-drill value.

**Step 23.** Stop the timer. Record elapsed time as your measured RTO.

---

### Runbook: Write and Commit

Create `week-8/runbook.md`. Use this exact format. Both Week 8 and Week 9 use structurally identical runbooks.

```markdown
**Incident:** Database data loss recovery

**Symptom:** Application returns errors or empty results for incident queries. Row count in incidents table drops to zero or table is missing.

**Root Cause:** Table or data directory deleted. Confirmed by: SELECT COUNT(*) FROM incidents returns error "relation does not exist."

**Fix:**
1. Stop application containers to prevent writes: docker compose stop flask nginx
2. Identify the most recent clean snapshot: restic snapshots
3. Restore data directory: restic restore <snapshot-id> --target /tmp/restore
4. Copy restored data to the Docker volume path
5. Restart the application: docker compose up -d
6. Verify row count matches pre-incident count

**Measured Before/After vs. Stated Target:**
- Row count before incident: [your value]
- Row count after restore: [your value]
- RTO target: 15 minutes
- Actual RTO: [your measured time]
```

Commit:

```bash
git add week-8/
git commit -m "feat: add MinIO backup pipeline, restic config, and recovery runbook"
git push origin main
```

---

### Storage Check

```bash
df -h
docker system df
```

The MinIO data volume and restic repository both consume disk. Record and compare to your Week 7 baseline in your Google Doc under "Week 8 Storage Check."

---

### Validation Checks

#### Validation Check: MinIO Is Running

```bash
docker ps --filter name=minio --format "{{.Status}}"
```

Expected: `Up X minutes`

#### Validation Check: At Least One restic Snapshot Exists

```bash
source week-8/restic-env.sh && restic snapshots
```

Expected: at least one snapshot row.

#### Validation Check: Recovery Drill Succeeded

Row count before the drill matches row count after recovery. Both documented in Google Doc and runbook.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week8.sh
```

---

### Deliverables

- `week-8/restic-env.sh` committed (credentials placeholdered or omitted)
- `.github/workflows/backup.yml` committed
- `week-8/runbook.md` committed using the required format
- Google Doc updated with recovery drill results (start time, end time, measured RTO, row count before and after)
- `./scripts/check-week8.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** `restic snapshots` showing at least one snapshot
- **Screenshot 2:** Application returning error after DROP TABLE
- **Screenshot 3:** Application returning correct row count after restore
- **Screenshot 4:** Backup workflow success in GitHub Actions
- **Screenshot 5:** `./scripts/check-week8.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. You measured an actual RTO during the recovery drill. How did your measured RTO compare to the 15-minute target? If it was over, which step took longest and what would you change?
2. Your retention policy keeps 7 daily, 4 weekly, and 3 monthly snapshots. A corruption is introduced on day 1 and goes undetected until day 10. Can you recover clean data? What would you change to guarantee recovery from a corruption that old?
3. restic encrypts backups by default. You stored the encryption password as a GitHub Actions secret. What are the risks of this approach, and what would a production team do differently?
4. The backup workflow runs at 02:00 UTC daily. What is your RPO based on this schedule? If the database is updated every 10 minutes, how much data is at risk in the worst case?
5. (Extend) Your backup target (MinIO) runs inside the same team container as your application. What class of failure would destroy both your application data AND your backups simultaneously? How would you redesign the backup target placement to survive that failure?

---

---

## Week 9: End-to-End Performance Investigation

**Sprint 5 Kickoff | Synchronous**

> **Pre-check required.** Week 9's CPU throttling diagnosis depends on Prometheus scraping `container_cpu_cfs_throttled_seconds_total`, configured in Week 5. Run the pre-check in Part 0 before proceeding. If the metric is unavailable, follow the inline fix before continuing.

### Overview

In this lab, your team loads the incident tracker with tens of thousands of synthetic records, then investigates two performance problems: a database-layer bottleneck exposed by query patterns at scale and an infrastructure-layer bottleneck caused by an intentionally low CPU limit. You will use k6 for load testing, Prometheus and Grafana for USE method diagnosis, `pg_stat_statements` and `EXPLAIN (ANALYZE, BUFFERS)` for database-layer diagnosis, and `rate(container_cpu_cfs_throttled_seconds_total[5m])` for infrastructure-layer diagnosis. The lab closes with a k6 threshold gate added to GitHub Actions. After completing this lab, you will have a performance runbook documenting both issues with measured before/after improvements and a regression gate in CI.

### Learning Objectives

- Use the USE method to identify which resource saturates first under load
- Diagnose a missing database index using `pg_stat_statements` and `EXPLAIN (ANALYZE, BUFFERS)`
- Diagnose CPU throttling using `rate(container_cpu_cfs_throttled_seconds_total[5m])`
- Add a k6 threshold gate to GitHub Actions as a permanent regression check

### Prerequisites

- Week 5 complete: Prometheus deployed with kubelet scraping verified (mandatory pre-check below)
- Week 8 complete: application has data in the database
- k6 installed from Week 5

---

### Part 0: Pre-Check -- Verify Week 5 Metric Is Available

**Step 0a.** Port-forward Prometheus.

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090 &
```

**Step 0b.** Query for the CPU throttling metric.

```bash
curl -s 'http://localhost:9090/api/v1/query?query=container_cpu_cfs_throttled_seconds_total' \
  | python3 -c "import json,sys; d=json.load(sys.stdin); r=d['data']['result']; print(f'PASS -- {len(r)} series') if r else print('FAIL -- no data')"
```

If `PASS`: proceed to Sprint Review.

If `FAIL`: Prometheus is not scraping kubelet. Fix before continuing:

1. Check kubelet ServiceMonitor: `kubectl get servicemonitor -n monitoring`
2. If missing, re-upgrade: `helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring -f week-5/prometheus-values.yaml`
3. Wait two minutes, re-run Step 0b. If still failing, raise with your TA.

---

### Sprint Review: Sprint 4

**Step 1.** Open the sprint board. Move all Sprint 4 items to Done.

**Step 2.** Sprint retrospective in Google Doc under "Sprint 4 Close."

**Step 3.** Environment checkpoint.

```bash
k3d cluster list
kubectl get pods
kubectl get pods -n monitoring
git log --oneline -5
```

**Step 4.** Assign Sprint 5 roles, open Sprint 5 issues.

---

### Part 1: Load the Database

**Step 5.** Run the shared seeder script provided by the professor.

```bash
python3 /path/to/seeder.py \
  --host localhost \
  --port 5432 \
  --database statustracker \
  --user appuser \
  --rows 50000
```

**Step 6.** Verify the row count.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
```

Expected: approximately 50,000 rows.

---

### Part 2: Baseline Load Test

**Step 7.** Create `week-9/smoke-test.js`.

```javascript
import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  vus: 5,
  duration: '1m',
  thresholds: {
    'http_req_duration': ['p(95)<500'],
    'http_req_failed': ['rate<0.01'],
  },
};

export default function () {
  const res = http.get('http://localhost:8080/incidents');
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  sleep(1);
}
```

**Step 8.** Run the smoke test and record the baseline.

```bash
k6 run week-9/smoke-test.js
```

Record: RPS, P50, P95, error rate. Add to Google Doc under "Week 9 Baseline."

---

### Part 3: Ramped Load Test and USE Method Diagnosis

**Step 9.** Apply the intentionally throttled CPU limit Deployment provided by the professor (CPU limit set to `100m`).

```bash
kubectl apply -f /path/to/flask-throttled-deployment.yaml
```

**Step 10.** Create `week-9/ramped-test.js`.

```javascript
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 10 },
    { duration: '3m', target: 50 },
    { duration: '1m', target: 0 },
  ],
};

export default function () {
  http.get('http://localhost:8080/incidents');
  sleep(0.5);
}
```

**Step 11.** Run the ramped test while watching Grafana.

```bash
k6 run week-9/ramped-test.js &
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 &
```

Watch the Flask USE Dashboard while the test runs.

**Step 12.** Query CPU throttling in Prometheus.

```bash
curl -s 'http://localhost:9090/api/v1/query?query=rate(container_cpu_cfs_throttled_seconds_total%7Bcontainer%3D"flask"%7D%5B5m%5D)' \
  | python3 -m json.tool
```

Record the throttle rate value. A value above 0 confirms throttling.

**Step 13.** Diagnose the database bottleneck.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker \
  -c "CREATE EXTENSION IF NOT EXISTS pg_stat_statements;"

docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker \
  -c "SELECT query, mean_exec_time, calls FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 5;"
```

Find the slowest query. Run `EXPLAIN (ANALYZE, BUFFERS)` against it.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker \
  -c "EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM incidents WHERE status = 'open' ORDER BY created_at DESC LIMIT 10;"
```

Look for `Seq Scan` in the output.

---

### Part 4: Fix Both Issues and Measure Improvement

**Step 14.** Fix the database issue. Add an index.

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker \
  -c "CREATE INDEX CONCURRENTLY idx_incidents_status_created ON incidents(status, created_at DESC);"
```

Run `EXPLAIN (ANALYZE, BUFFERS)` again. Confirm `Index Scan` replaces `Seq Scan`.

**Step 15.** Fix the infrastructure issue. Update the Flask Deployment CPU limit from `100m` to `500m` in `manifests/flask-deployment.yaml`.

```bash
kubectl apply -f manifests/flask-deployment.yaml
```

**Step 16.** Re-run the ramped test.

```bash
k6 run week-9/ramped-test.js
```

Record: RPS, P50, P95, error rate. Compare to the Week 9 baseline.

**Step 17.** Query CPU throttling again.

```bash
curl -s 'http://localhost:9090/api/v1/query?query=rate(container_cpu_cfs_throttled_seconds_total%7Bcontainer%3D"flask"%7D%5B5m%5D)' \
  | python3 -m json.tool
```

The throttle rate should be near zero.

---

### Part 5: Add k6 Threshold Gate to CI

**Step 18.** Update `.github/workflows/ci.yml` with a k6 threshold check job.

```yaml
  load-test-gate:
    runs-on: ubuntu-latest
    needs: build-and-push

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install k6
        run: |
          curl https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz -Lo /tmp/k6.tar.gz
          tar -xzf /tmp/k6.tar.gz -C /tmp
          sudo mv /tmp/k6-v0.47.0-linux-amd64/k6 /usr/local/bin/k6

      - name: Run k6 smoke test threshold gate
        run: k6 run week-9/smoke-test.js
```

The `p(95)<500` threshold in `smoke-test.js` causes this job to fail if P95 exceeds 500ms.

**Step 19.** Commit all changes.

```bash
git add week-9/ manifests/ .github/
git commit -m "feat: load tests, fix CPU throttling and missing index, add k6 CI gate"
git push origin main
```

---

### Runbook: Write and Commit

Create `week-9/runbook.md` using the same structure as the Week 8 runbook.

```markdown
**Incident 1:** CPU throttling under load

**Symptom:** P95 response time exceeds 500ms during ramped load test. Grafana CPU saturation panel shows non-zero throttle rate.

**Root Cause:** Flask Deployment CPU limit set to 100m. At 50 VUs, the container requests more CPU than the limit allows.

**Fix:**
1. Confirm throttling: rate(container_cpu_cfs_throttled_seconds_total{container="flask"}[5m]) > 0
2. Identify the limit: kubectl get deployment flask -o yaml | grep -A5 resources
3. Update cpu limit from 100m to 500m in manifests/flask-deployment.yaml
4. Apply: kubectl apply -f manifests/flask-deployment.yaml
5. Re-run load test and confirm throttle rate drops to near zero

**Measured Before/After vs. Stated Target:**
- P95 before fix: [your value]ms
- P95 after fix: [your value]ms
- CPU throttle rate before: [your value]
- CPU throttle rate after: [your value]
- Target: P95 < 500ms

---

**Incident 2:** Sequential scan on incidents table

**Symptom:** pg_stat_statements shows high mean_exec_time. EXPLAIN ANALYZE shows Seq Scan on 50,000 rows.

**Root Cause:** No index on (status, created_at). Full table scan required for every filtered/sorted query.

**Fix:**
1. Confirm: EXPLAIN (ANALYZE, BUFFERS) shows "Seq Scan on incidents"
2. Create index: CREATE INDEX CONCURRENTLY idx_incidents_status_created ON incidents(status, created_at DESC)
3. Verify: re-run EXPLAIN ANALYZE, confirm "Index Scan" appears

**Measured Before/After vs. Stated Target:**
- Mean query time before index: [your value]ms
- Mean query time after index: [your value]ms
- P95 before: [your value]ms
- P95 after: [your value]ms
- Target: P95 < 500ms
```

---

### Storage Check

```bash
df -h
docker system df
kubectl top pods
```

Record in Google Doc under "Week 9 Storage Check."

---

### Validation Checks

#### Validation Check: Seeded Row Count

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker -c "SELECT COUNT(*) FROM incidents;"
```

Expected: approximately 50,000 rows.

#### Validation Check: CPU Throttle Rate Near Zero After Fix

```bash
curl -s 'http://localhost:9090/api/v1/query?query=rate(container_cpu_cfs_throttled_seconds_total{container="flask"}[5m])' \
  | python3 -c "import json,sys; d=json.load(sys.stdin); v=float(d['data']['result'][0]['value'][1]) if d['data']['result'] else 0; print('PASS' if v < 0.01 else f'FAIL -- throttle rate {v}')"
```

Expected: `PASS`

#### Validation Check: Index Exists

```bash
docker compose -f week-2/docker-compose.yml exec db \
  psql -U appuser -d statustracker \
  -c "\di idx_incidents_status_created"
```

Expected: one row listing `idx_incidents_status_created`.

#### Validation Check: k6 Smoke Test Passes Threshold

```bash
k6 run week-9/smoke-test.js
```

Expected: all thresholds passing in k6 output.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week9.sh
```

---

### Deliverables

- `week-9/smoke-test.js` and `week-9/ramped-test.js` committed
- `week-9/runbook.md` committed using the two-incident format
- `manifests/flask-deployment.yaml` updated with corrected CPU limit
- `.github/workflows/ci.yml` updated with k6 threshold gate
- Google Doc updated with baseline vs. post-fix comparison numbers
- `./scripts/check-week9.sh` runs clean

**Screenshot requirements:**

- **Screenshot 1:** Prometheus query showing non-zero throttle rate before fix
- **Screenshot 2:** `EXPLAIN ANALYZE` output showing Seq Scan (before index)
- **Screenshot 3:** `EXPLAIN ANALYZE` output showing Index Scan (after index)
- **Screenshot 4:** k6 output after fixes showing thresholds passing
- **Screenshot 5:** `./scripts/check-week9.sh` passing

---

### Reflection Questions (Answer in Google Doc)

1. You found two performance problems: one at the database layer and one at the infrastructure layer. Which caused more impact to P95 response time? How do you know?
2. The k6 threshold gate fails CI if P95 exceeds 500ms. Name a scenario where this threshold would produce a false positive (fails CI even though the application is actually fine). How would a team tune the threshold to reduce false positives?
3. You used `pg_stat_statements` to find slow queries. This extension has overhead because it records every query. Under what circumstances would you disable it in production?
4. After adding the index, reads became index scans instead of sequential scans. Indexes consume disk space and slow down write operations. How would you decide whether the read improvement justifies the write overhead?
5. (Extend) The CPU limit was set to 100m in the throttled manifest. In a real team, how would you prevent an under-resourced Deployment from being merged to main? What process or automated check would catch it?

---

---

## Weeks 10-14: Challenge Track Sprints

**Sprints 5-7**

---

### Overview: Weeks 10-14 Structure

Weeks 10-14 are organized around six challenge tracks. Each team selects one track at the end of Week 9.

> **Note:** These weeks were flagged in the Disconnection Notes as needing re-evaluation with the professor before being finalized. The six tracks and the overall structure below are correct; specific deliverables and integration points may be adjusted after that conversation. Present this section as a framework.

| Week | Sprint | Type | Focus |
|---|---|---|---|
| Week 10 | Sprint 5 (cont.) | Synchronous | Challenge kickoff, architecture decision, backlog |
| Week 11 | Sprint 6 | Asynchronous | Core build: implement the challenge |
| Week 12 | Sprint 6 (cont.) | Asynchronous | Challenge build continued, integration testing |
| Week 13 | Sprint 7 | Synchronous | Finalize, Ansible dry run, demo rehearsal |
| Week 14 | Sprint 7 (cont.) | Synchronous | Demo Day: container wipe and playbook rebuild |

**Ansible capstone thread:** Each team's `ansible/site.yml` must include the challenge tooling before Demo Day. During Week 14, the professor wipes the container and your team runs `ansible-playbook ansible/site.yml` to rebuild the full environment live. The rebuild must complete without manual steps.

---

### The Six Challenge Tracks

Each team selects one track. Selection is made at the end of Week 9.

| Track | Focus | Core tooling added |
|---|---|---|
| Applied Data Science | Data analysis and visualization pipelines | JupyterLab, pandas, matplotlib, PostgreSQL analytics queries |
| Cybersecurity and Governance | Audit, compliance scanning, policy enforcement | OPA/Gatekeeper or Kyverno, Falco, kube-bench |
| DevSecOps | Security integrated into the CI/CD pipeline | SBOM generation, DAST scanning, gitleaks or trufflehog |
| Machine Learning and AI | ML model serving and inference pipeline | MLflow, scikit-learn, FastAPI inference endpoint |
| Network and Cloud Infrastructure | Advanced networking and multi-cluster patterns | Linkerd service mesh (or Cilium if supported) |
| Data Management and Analytics | Data engineering pipelines and analytics | dbt, PostgreSQL analytics schema, Grafana or Superset |

---

## Week 10: Challenge Kickoff

**Sprint 5 Continuation | Synchronous**

### Overview

Week 10 is the challenge kickoff session. Your team selects a challenge track, documents the rationale, makes an architecture decision, defines your Sprint 5 and 6 backlogs, and identifies what tooling your Ansible playbook will need to install to support the challenge. The deliverables this week are planning artifacts, not implementation. After completing Week 10, your team has a written architecture decision record, sprint backlogs with acceptance criteria, and a confirmed understanding of what your Demo Day rebuild requires.

### Learning Objectives

- Select a challenge track and document the rationale
- Produce an architecture decision record for the challenge approach
- Identify what Ansible roles will be needed to support the challenge on Demo Day
- Define Sprint 5 and Sprint 6 backlogs with acceptance criteria per ticket

---

### Part 1: Challenge Selection and Rationale

**Step 1.** As a group, discuss the six challenge tracks. Every team member should have read the track descriptions before the session.

**Step 2.** Make a selection. Record a one-paragraph justification in your Google Doc under "Sprint 5 -- Challenge Selection": why this track fits your team's goals, what you expect to learn, and what you expect to find difficult.

**Step 3.** Identify the primary tool(s) your selected track introduces. For each, answer:
- What does it do?
- How does it interact with the infrastructure you have already built?
- What needs to be installed or configured in the container?

---

### Part 2: Architecture Decision Record

**Step 4.** Create `week-10/adr.md`.

```markdown
# ADR-001: Challenge Track Architecture

**Challenge Track:** [name]
**Decision date:** [date]

## Context
[2-3 sentences on the problem this track addresses and why it is relevant to your application.]

## Decision
[1-2 sentences on what your team will build.]

## Options considered
1. [Option A] -- [one sentence description]
2. [Option B] -- [one sentence description]

## Rationale
[Why you chose the option you did. One paragraph.]

## Consequences
[What becomes easier? What becomes harder?]

## Ansible integration plan
[List what roles or tasks will be added to ansible/site.yml for this track's tooling. This must be complete before Demo Day.]
```

**Step 5.** Commit the ADR.

```bash
git add week-10/
git commit -m "docs: add challenge track ADR for Sprint 5"
git push origin main
```

---

### Part 3: Sprint 5 and Sprint 6 Backlog

**Step 6.** The Scrum Master creates Sprint 5 and Sprint 6 issues on the GitHub project board. Each issue must include a description, at least two acceptance criteria, and an assigned owner.

**Step 7.** Estimate each ticket using T-shirt sizing (S/M/L). Rebalance if any team member is over or under loaded before leaving today.

---

### Validation Checks

#### Validation Check: ADR Is Committed and Complete

```bash
cat week-10/adr.md
```

All required sections present.

#### Validation Check: Sprint Backlogs Have Acceptance Criteria

Every Sprint 5 and Sprint 6 ticket on the project board has at least two acceptance criteria.

---

### Deliverables

- `week-10/adr.md` committed with all sections complete
- GitHub project board updated with Sprint 5 and Sprint 6 issues
- Google Doc updated with challenge selection rationale
- `./scripts/check-week10.sh` runs clean

---

---

## Week 11: Challenge Build -- Part 1

**Sprint 6 Async | First week of core build**

### Overview

Week 11 is the first implementation week for your challenge track. By the end of Week 11, your team must have the primary tooling installed, running, and integrated with at least one component of your existing application stack.

### All Tracks: Required This Week

**Step 1.** Install the primary challenge tool(s) inside the team container. Verify they run.

**Step 2.** Add a new Ansible role to `ansible/site.yml` that installs and configures the primary challenge tool(s). The role must be idempotent.

```bash
mkdir -p ansible/roles/[challenge-role-name]/tasks
```

**Step 3.** Run the full playbook to verify it still passes.

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

**Step 4.** Commit the new role.

```bash
git add ansible/
git commit -m "feat: add [challenge-name] role to site.yml"
git push origin main
```

**Step 5.** Update your Google Doc with Week 11 progress: what was built, what is blocked, what each team member contributed.

**Step 6.** Storage check.

```bash
df -h
docker system df
```

Record in Google Doc under "Week 11 Storage Check."

---

### Validation Checks

#### Validation Check: Ansible Playbook Still Passes

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Expected: `PLAY RECAP` shows `failed=0` for all plays.

#### Validation Check: Challenge Tool Is Running

Run the track-specific verification command listed in the Appendix.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week11.sh
```

---

### Deliverables

- Primary challenge tool installed and verified
- New Ansible role committed to `ansible/site.yml`
- Ansible playbook still passes after role addition
- Google Doc updated with Week 11 progress
- `./scripts/check-week11.sh` runs clean

---

---

## Week 12: Challenge Build -- Part 2

**Sprint 6 Async (continued)**

### Overview

Week 12 is the second implementation week. Your team finishes the core challenge implementation and runs integration testing between the challenge tooling and the application stack. By end of Week 12, the challenge deliverable must be in a state where a demo is possible.

### All Tracks: Required This Week

**Step 1.** Complete any remaining implementation from Week 11.

**Step 2.** Run integration tests. Verify that the challenge tooling did not break the base application.

```bash
curl http://localhost:8080/incidents
k6 run week-9/smoke-test.js
```

Both must pass.

**Step 3.** Run a dry-run demo rehearsal. One team member plays the professor, others walk through the demo as if it were Demo Day. Record what was unclear or incomplete.

**Step 4.** Write `week-12/demo-plan.md`:

```markdown
# Demo Plan

**Challenge Track:** [name]
**Demo date:** Week 14

## Demo sequence
1. [Step: who demonstrates what]
2. [Step: who demonstrates what]
...

## What can go wrong and how we recover
- [Risk]: [recovery plan]

## The one thing that best shows the challenge-to-application integration
[One paragraph.]
```

**Step 5.** Run the full Ansible playbook.

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

**Step 6.** Commit all Week 12 work.

**Step 7.** Update Google Doc with Week 12 progress, dry run observations, and storage check.

---

### Validation Checks

#### Validation Check: Base Application Still Works

```bash
curl http://localhost:8080/incidents
k6 run week-9/smoke-test.js
```

Both must pass.

#### Validation Check: Ansible Playbook Passes

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Expected: `failed=0` for all plays.

#### Validation Check: Check Script Passes

```bash
./scripts/check-week12.sh
```

---

### Deliverables

- Challenge implementation feature-complete
- `week-12/demo-plan.md` committed
- All validation checks pass
- Google Doc updated with Week 12 progress and dry run notes

---

---

## Week 13: Finalize, Dry Run, and Demo Prep

**Sprint 7 Kickoff | Synchronous**

### Overview

Week 13 is the last synchronous session before Demo Day. Your team runs the Ansible playbook dry run, rehearses the demo with the professor observing, and resolves any remaining gaps. After this session, your Ansible playbook must be able to rebuild the full environment from a cold start without manual steps.

### Learning Objectives

- Run `ansible-playbook --check` and interpret dry-run output
- Identify and fix gaps in the playbook before Demo Day
- Deliver a complete demo rehearsal with the professor observing
- Commit all outstanding work with Sprint 7 board updated

### Sprint Review: Sprint 6

**Step 1.** Open the sprint board. Move all Sprint 6 items to Done or note what remains.

**Step 2.** Sprint 6 retrospective in Google Doc under "Sprint 6 Close."

**Step 3.** Environment checkpoint. Paste output into Google Doc.

**Step 4.** Assign Sprint 7 roles.

---

### Part 1: Ansible Dry Run

**Step 5.** Run the playbook in check mode.

```bash
ansible-playbook ansible/site.yml --check
```

Review the output. Every task that would make a change is flagged.

**Step 6.** Fix all issues the dry run reveals. Common problems at this stage:

- A task fails in check mode because it depends on a file that doesn't exist yet (ordering issue)
- A task shows `changed` on every run (not idempotent -- does not check before acting)
- A role is missing from `site.yml` because it was added manually in the container but not committed

**Step 7.** Re-run the dry run and repeat until the output shows no unexpected changes.

**Step 8.** Commit all playbook fixes.

```bash
git add ansible/
git commit -m "fix: resolve dry-run issues in site.yml for Demo Day readiness"
git push origin main
```

---

### Part 2: Demo Rehearsal

**Step 9.** Run through the demo with the professor observing. Use `demo-plan.md` as the script.

Demo must cover:
1. Application responding to API calls
2. Monitoring: at least one Grafana panel with live data
3. Challenge track integration: one end-to-end demonstration
4. Ansible rebuild claim: show the playbook and describe what it rebuilds

**Step 10.** After the rehearsal, the professor provides feedback. The Scrum Master records all feedback in the Google Doc under "Week 13 Demo Feedback."

**Step 11.** Create tickets for every piece of professor feedback. Assign owners and estimate size before leaving.

---

### Validation Checks

#### Validation Check: Ansible Dry Run Produces No Unexpected Changes

```bash
ansible-playbook ansible/site.yml --check
```

Expected: `changed=0` for every play in the PLAY RECAP.

#### Validation Check: All Weeks' Check Scripts Pass

```bash
for week in 1 2 3 4 5 6 7 8 9 10 11 12 13; do
  echo "=== Week ${week} ==="
  ./scripts/check-week${week}.sh
done
```

All must pass before Demo Day.

---

### Deliverables

- Ansible dry run showing `changed=0` for all plays
- All weekly check scripts passing
- Demo feedback recorded in Google Doc
- Outstanding feedback items as tickets on the project board
- All work committed to main

**Screenshot requirements:**

- **Screenshot 1:** `ansible-playbook --check` PLAY RECAP showing `changed=0` for all plays
- **Screenshot 2:** All weekly check scripts passing

---

### Reflection Questions (Answer in Google Doc)

1. The Ansible dry run revealed tasks that would change even though the environment looks correct. What does this tell you about those tasks? How do you write a task so it only makes changes when something is actually wrong?
2. Your demo plan from Week 12 was refined based on professor feedback. What was the gap between what you planned to show and what actually worked?
3. Across the semester, which Ansible role was the most difficult to write idempotently? What made it hard?
4. If a teammate who was not in this class cloned your repository and ran `ansible-playbook site.yml`, what would they get? What would still be missing?

---

---

## Week 14: Demo Day

**Sprint 7 Close | Synchronous | Capstone**

### Overview

Demo Day is the capstone of the semester. The professor wipes your team container. Your team then runs `ansible-playbook ansible/site.yml` to rebuild the entire environment from your committed code. After the rebuild, you deliver the full demo. After completing Demo Day, you will have demonstrated that your entire semester's work is reproducible from version control, which is the core claim of infrastructure as code.

### Prerequisites

- All weeks complete and committed to the repository
- `ansible/site.yml` dry run (`--check`) passed in Week 13 with `changed=0`
- All weekly check scripts passing

---

### Part 1: The Container Wipe

The professor wipes your team container at the start of Demo Day. Removed: all manually installed tools, running containers, cluster state, and files outside the repository.

What survives the wipe:
- Your cloned repository (on a mounted volume preserved by the professor)
- All code and configuration committed to GitHub

What does NOT survive:
- The nested Docker daemon and any containers it was running
- k3d cluster state
- OpenTofu state file
- restic repository and MinIO data
- Tools installed by hand but not committed to Ansible

**Step 1.** After the professor signals the wipe is complete, clone your repository.

```bash
git clone https://github.com/[your-org]/inet4031-team-[number].git
cd inet4031-team-[number]
```

**Step 2.** Install Ansible if not pre-installed.

```bash
apt-get update && apt-get install -y ansible
```

---

### Part 2: Playbook Rebuild

**Step 3.** Start the rebuild timer.

**Step 4.** Run the full Ansible playbook.

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

The playbook installs (in order):
- Play 1 (baseline): baseline packages and Docker
- Play 2 (app-stack): Docker Compose application stack
- Play 3 (k3d-setup): k3d cluster
- Play 4 (opentofu-setup): OpenTofu
- Play 5 ([challenge-role-name]): challenge track tooling

**Step 5.** After the playbook completes, verify the rebuild.

```bash
docker ps
k3d cluster list
kubectl get pods
tofu version
```

**Step 6.** Stop the rebuild timer. Record total elapsed time in your Google Doc under "Demo Day -- Rebuild Time."

---

### Part 3: Demo

**Step 7.** Deliver the demo using your plan from Week 12 (refined from Week 13 feedback).

Demo sequence (minimum, in order):
1. Application is running: `curl http://localhost:8080/incidents` returns data
2. Monitoring: Grafana dashboard with live data
3. Challenge track: end-to-end demonstration
4. Automated rebuild: show the `ansible-playbook` output and rebuild time

**Step 8.** Each team member explains their contribution to at least one part of the semester's work. The professor may ask questions about any week.

---

### Validation Checks

#### Validation Check: Playbook Runs Clean After Wipe

```bash
ansible-playbook -i ansible/inventory ansible/site.yml
```

Expected: `PLAY RECAP` shows `failed=0` and `unreachable=0` for all plays.

#### Validation Check: Application Responds After Rebuild

```bash
curl http://localhost:8080/incidents
```

Expected: valid JSON response.

#### Validation Check: Cluster Is Running After Rebuild

```bash
k3d cluster list
kubectl get nodes
```

Expected: cluster running, all nodes Ready.

---

### Deliverables

- Live container wipe followed by successful `ansible-playbook` rebuild (witnessed by professor)
- Full demo delivered with all components running
- Rebuild time recorded in Google Doc
- Google Doc contains complete semester's reflection entries for all weeks
- All repository branches merged, project board shows Sprint 7 complete

**Screenshot requirements:**

- **Screenshot 1:** `ansible-playbook` PLAY RECAP after wipe showing `failed=0` for all plays
- **Screenshot 2:** Application responding to API call after rebuild
- **Screenshot 3:** `k3d cluster list` and `kubectl get nodes` showing cluster running

---

### Final Reflection (Answer in Google Doc)

1. What was the single hardest technical problem your team solved this semester? Walk through how you diagnosed it and what you learned from the diagnosis process, not just the fix.
2. Infrastructure as code promises that your environment is reproducible from version control. Where did you find the gap between that promise and what you actually committed? What would a more complete implementation look like?
3. Over the semester, you rotated through at least three different roles. Which role changed your understanding of how the other roles work?
4. Your application ran in three different forms: Docker Compose (Week 2), Kubernetes (Week 3+), and automated rebuild (Week 14). What did each transition reveal about the previous form's limitations?
5. If your team were hired as a real infrastructure team running a similar stack, what is the first thing you would change about what you built? What is the thing you are most confident about?

---

---

## Appendix: Challenge Track Reference Details

### Track 1: Applied Data Science

**Goal:** Build an analytics pipeline on top of the incident data, producing reproducible analysis with meaningful visualizations.

**Core tools:** JupyterLab, pandas, matplotlib, SQLAlchemy.

**Week 11 deliverable:** JupyterLab running in a container, accessible on a port from the team container. One notebook connected to PostgreSQL and reading from the incidents table.

**Week 12 deliverable:** Three analytical deliverables: (1) a time-series visualization of incident volume by day, (2) a status distribution breakdown, (3) a statistical summary comparing response times across status categories. All analysis uses real data from the seeded incidents table.

**Ansible integration:** A role that installs JupyterLab and starts it as a background service. Must be idempotent.

**Verification command:**

```bash
curl -s http://localhost:8888/api | python3 -c "import json,sys; d=json.load(sys.stdin); print('JupyterLab up') if 'version' in d else print('FAIL')"
```

---

### Track 2: Cybersecurity and Governance

**Goal:** Add automated compliance scanning and runtime policy enforcement to the Kubernetes cluster.

**Core tools:** kube-bench, OPA/Gatekeeper or Kyverno, Falco.

**Week 11 deliverable:** kube-bench run against the k3d cluster with findings documented. At least one policy deployed that prevents pods from running as root.

**Week 12 deliverable:** A policy enforcement demo where a manifest that violates the policy is rejected by the admission controller. Evidence that Falco is generating audit events. A compliance report documenting kube-bench findings and which controls your policies address.

**Ansible integration:** A role that installs kube-bench and deploys the admission controller policy.

**Verification command:**

```bash
kubectl get constrainttemplate 2>/dev/null && echo "Gatekeeper installed" || kubectl get clusterpolicy 2>/dev/null && echo "Kyverno installed" || echo "FAIL"
```

---

### Track 3: DevSecOps

**Goal:** Extend the CI/CD pipeline with automated security checks that gate merges.

**Core tools:** Grype or Trivy (SBOM generation), gitleaks or trufflehog (secrets detection), OWASP ZAP (DAST).

**Week 11 deliverable:** SBOM generation added to CI. Secrets detection added as a CI step that scans the repository for committed secrets.

**Week 12 deliverable:** OWASP ZAP automated scan run against the application with results documented. A pipeline that blocks a merge when: (a) a CRITICAL vulnerability is found in the image, (b) secrets are detected in a commit. Evidence that both blocks work by triggering them in a test branch.

**Ansible integration:** A role that installs grype or Trivy inside the container for local scanning.

**Verification command:**

```bash
which grype 2>/dev/null && echo "grype installed" || which trivy 2>/dev/null && echo "trivy installed" || echo "FAIL"
```

---

### Track 4: Machine Learning and AI

**Goal:** Build an ML model serving pipeline integrated with the incident data.

**Core tools:** MLflow, scikit-learn, FastAPI inference endpoint.

**Week 11 deliverable:** MLflow tracking server running in a container. A simple model (incident severity classifier or time-to-resolution predictor) trained on the seeded data and logged to MLflow with metrics.

**Week 12 deliverable:** The model served behind a FastAPI inference endpoint accessible within the cluster. At least one call from the Flask application to the inference endpoint. MLflow UI showing the training run, metrics, and registered model.

**Ansible integration:** A role that installs MLflow and starts the tracking server.

**Verification command:**

```bash
curl -s http://localhost:5001/health 2>/dev/null && echo "MLflow up" || echo "FAIL"
```

---

### Track 5: Network and Cloud Infrastructure

**Goal:** Implement advanced network controls and service-to-service observability beyond the NetworkPolicy applied in Week 7.

**Core tools:** Linkerd (service mesh with mTLS and traffic observability). If Linkerd cannot be installed in your k3d version, confirm with your TA before starting.

**Week 11 deliverable:** Linkerd installed in the k3d cluster. Flask-to-PostgreSQL traffic path meshed. mTLS verified between Flask and PostgreSQL using `linkerd check` output.

**Week 12 deliverable:** A Grafana dashboard showing service-to-service traffic latency and success rate from Linkerd metrics. A demonstration of what happens when a NetworkPolicy intentionally blocks a meshed path.

**Ansible integration:** A role that installs the Linkerd CLI and applies the Linkerd control plane.

**Verification command:**

```bash
linkerd check 2>/dev/null | tail -3 && echo "Linkerd verified" || echo "FAIL or not installed"
```

---

### Track 6: Data Management and Analytics

**Goal:** Build a data engineering pipeline that transforms incident data into an analytics model.

**Core tools:** dbt with PostgreSQL adapter, Grafana or Apache Superset.

**Week 11 deliverable:** dbt installed. A dbt project initialized and connected to PostgreSQL. At least two dbt models: one staging model (raw incidents) and one mart model (aggregated by status and time window).

**Week 12 deliverable:** dbt models running on a cron schedule via GitHub Actions. A dashboard showing metrics derived from dbt mart models (not raw application tables). Evidence that dbt schema tests pass (uniqueness, not-null).

**Ansible integration:** A role that installs dbt and its PostgreSQL adapter.

**Verification command:**

```bash
dbt --version 2>/dev/null && echo "dbt installed" || echo "FAIL"
```

---

*End of INET 4031 Lab Directions -- Full Curriculum (Proposed)*

*Document generated as a design proposal for professor review. All content from Week 3 onward is contingent on the university's container platform supporting `--privileged` mode. Do not treat this as a finalized curriculum until that assumption is confirmed.*
