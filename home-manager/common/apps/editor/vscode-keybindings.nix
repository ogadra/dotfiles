[
    {
        key     = "ctrl+tab";
        command = "workbench.action.nextEditor";
    }
    {
        key     = "ctrl+shift+tab";
        command = "workbench.action.previousEditor";
    }
    {
        key     = "pageup";
        command = "-cursorPageUp";
        when    = "textInputFocus";
    }
    {
        key     = "pagedown";
        command = "-cursorPageDown";
        when    = "textInputFocus";
    }
    {
        key     = "meta+b";
        command = "-editor.action.toggleSidebarVisibility";
    }
    {
        key     = "shift+meta+2";
        command = "workbench.action.splitEditorRight";
    }
    {
        key     = "alt+meta+n";
        command = "workbench.action.duplicateWorkspaceInNewWindow";
    }
    {
        key     = "alt+enter";
        command = "-testing.editFocusedTest";
        when    = "focusedView == 'workbench.view.testing'";
    }
    {
        key     = "ctrl+shift+enter";
        command = "testing.runAtCursor";
        when    = "editorTextFocus";
    }
    {
        key     = "alt+1";
        command = "workbench.action.focusFirstEditorGroup";
    }
    {
        key     = "alt+2";
        command = "workbench.action.focusSecondEditorGroup";
    }
    {
        key     = "alt+3";
        command = "workbench.action.focusThirdEditorGroup";
    }
]
