-- Insert default roles
INSERT INTO roles (id, name, description)
VALUES
    (gen_random_uuid(), 'ROLE_ADMIN', 'Administrator role with full access'),
    (gen_random_uuid(), 'ROLE_PROFESSOR', 'Professor role with teaching privileges'),
    (gen_random_uuid(), 'ROLE_STUDENT', 'Student role with learning access')
ON CONFLICT (name) DO NOTHING;