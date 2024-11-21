```mermaid
erDiagram
    users {
        int user_id PK
        string name
        string email
        string password_digest
        int corporate_id FK
        string status
        datetime last_login_at
        int role_id FK
        int search_queries_ID FK
    }
    notification_users {
        int notification_user_id PK
        int notification_id FK
        int user_id FK
        boolean read
    }
    notifications {
        int notification_id PK
        int project_id FK
        string notification_content
    }
    projects {
        int project_id PK
        string project_name
        int partner_id FK
        int status_id FK
        string product_name
        datetime construction_date
        datetime created_at
        datetime updated_at
    }
    project_histories {
        int project_history_id PK
        int project_id FK
        int status_id FK
        string comment
        int users_id FK
    }
    project_history_files {
        int project_history_file_id PK
        int project_history_id FK
        int file_id FK
    }
    files {
        int file_id PK
        string file_name
        string file_path
        string file_url
        int file_size
        string file_type
        int users_id FK
    }
    roles {
        int role_id PK
        string name
        string description
    }
    role_statuses {
        int role_statuse_id PK
        int role_id FK
        int status_id FK
        string custom_statuse
    }
    statuses {
        int status_id PK
        string name
        string description
        int display_order
    }
    partners {
        int partner_id PK
        string partner_name
        string partner_code
        int corporate_id FK
        string address
        string phone
        string email
    }
    corporates {
        int corporate_id PK
        string corporate_name
        string corporate_code
        string address
        string phone
        string email
    }
    search_queries {
        int search_query_id PK
        string query_name
        string search_keywords
        string filters
        int users_id FK
    }
    tags {
        int tag_id PK
        string name
    }
    tagging {
        int tagging_id PK
        int tag_id FK
        int project_id FK
    }

    %% Relationships
    users ||--o| corporates: "belongs to"
    users ||--o| roles: "has"
    users ||--o| search_queries: "has"
    users ||--o| project_histories: "creates"
    users ||--o| files: "uploads"
    users ||--o| notification_users: "receives"
    roles ||--o| role_statuses: "defines"
    statuses ||--o| role_statuses: "belongs to"
    projects ||--o| partners: "assigned to"
    projects ||--o| statuses: "has"
    projects ||--o| project_histories: "has"
    projects ||--o| notifications: "receives"
    project_histories ||--o| project_history_files: "has"
    project_histories ||--o| project_histories: "linked"
    project_history_files ||--o| files: "references"
    search_queries ||--o| users: "belongs to"
    tagging ||--o| tags: "has"
    tagging ||--o| projects: "assigned to"
    corporates ||--o| partners: "owns"
