--  VERSION @SV_VERSION@
--
--    NAME
--      _install_app.sql
--
--    DESCRIPTION
--      Shell Script used to install the eFramework APEX applications
--
--    NOTES
--      Assumes the SYS user is connected.
--
--    Arguments:
--      ^1 = app_file
--      ^2 = app_id
--
--    MODIFIED   (MM/DD/YYYY)
--      tsthilaire   16-FEB-2014  - Created   
--
--

--  feedback - Displays the number of records returned by a script ON=1
set feedback off
--  termout - display of output generated by commands in a script that is executed
set termout on
-- serverout - allow dbms_output.put_line
set serverout off
--  define - Sets the character used to prefix substitution variables
set define '^'
--  concat - Sets the character used to terminate a substitution variable ON=.
set concat on
--  verify off prevents the old/new substitution message
set verify off

-- read the script parameters
def script_app_file ='^1'
def script_app_id   ='^2'

PROMPT  =============================================================================
PROMPT  == Application File ^script_app_file Start
PROMPT  =============================================================================
PROMPT

-- Check if the application ID already exists for SERT
DECLARE
  l_workspace     varchar2(20) := 'SERT';
  l_workspace_id  number;
  l_app_id_check  NUMBER;
BEGIN

-- Set the Application Alias
IF '^script_app_file' = 'sert_apex.sql' THEN
  apex_application_install.set_application_alias('SERT');
ELSIF '^script_app_file' = 'sert_admin.sql' THEN
  apex_application_install.set_application_alias('SERT_ADMIN');
END IF;

-- Get the Workspace Name ID value
SELECT workspace_id
  INTO l_workspace_id
  FROM apex_workspaces
  WHERE workspace = l_workspace;
  
-- Workspace Security
apex_application_install.set_workspace_id( l_workspace_id );
apex_application_install.generate_offset;
  
-- assign ID or auto generate
IF '^script_app_id'>=1 THEN
  -- ID given - use the one they provided
    apex_application_install.set_application_id('^script_app_id'); 
ELSE
  -- No ID given - auto generate
  APEX_APPLICATION_INSTALL.GENERATE_APPLICATION_ID;
END IF;

EXCEPTION WHEN NO_DATA_FOUND then
    dbms_output.put_line('ISSUE: The workspace SERT does not exist at this time.');
    raise VALUE_ERROR;
END;
/

@@^script_app_file
PROMPT  =============================================================================
PROMPT  == Changing Application Settings
PROMPT  =============================================================================
PROMPT

--  define - Sets the character used to prefix substitution variables
set define '^'

DECLARE
  l_app_id        NUMBER;
  l_workspace     VARCHAR2(20) := 'SERT';
  l_workspace_id  NUMBER;
BEGIN

IF '^script_app_file' = 'sert_apex.sql' THEN
  SELECT application_id INTO l_app_id FROM apex_applications WHERE alias = 'SERT';
ELSIF '^script_app_file' = 'sert_admin.sql' THEN
  SELECT application_id INTO l_app_id FROM apex_applications WHERE alias = 'SERT_ADMIN';
END IF;

SELECT workspace_id
  INTO l_workspace_id
  FROM apex_workspaces
  WHERE workspace = l_workspace;
  
-- Workspace Security
apex_application_install.set_workspace_id(l_workspace_id);

wwv_flow_api.set_flow_status 
  (
  p_flow_id     => l_app_id,
  p_flow_status => 'AVAILABLE'
  );
    
wwv_flow_api.set_build_status_run_only 
  (
  p_flow_id     => l_app_id
  );

wwv_flow_api.set_enable_app_debugging 
  (
  p_flow_id     => l_app_id,
  p_debugging   => 0
  );

END;
/

-- clear installation settings (prevents collisions)
exec APEX_APPLICATION_INSTALL.CLEAR_ALL;

--  define - Sets the character used to prefix substitution variables
set define '^'
PROMPT  =============================================================================
PROMPT  == Application File ^script_app_file Complete
PROMPT  =============================================================================
PROMPT