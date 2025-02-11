" Author: Dalius Dobravolskas <dalius.dobravolskas@gmail.com>
" Description: https://github.com/pappasam/jedi-language-server

call ale#Set('python_jedils_executable', 'jedi-language-server')
call ale#Set('python_jedils_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_jedils_auto_pipenv', 0)
call ale#Set('python_jedils_auto_poetry', 0)
call ale#Set('python_jedils_auto_uv', 0)

function! ale_linters#python#jedils#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_jedils_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'python_jedils_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    if (ale#Var(a:buffer, 'python_auto_uv') || ale#Var(a:buffer, 'python_jedils_auto_uv'))
    \ && ale#python#UvPresent(a:buffer)
        return 'uv'
    endif

    return ale#python#FindExecutable(a:buffer, 'python_jedils', ['jedi-language-server'])
endfunction

function! ale_linters#python#jedils#GetCommand(buffer) abort
    let l:executable = ale_linters#python#jedils#GetExecutable(a:buffer)
    let l:exec_args = l:executable =~? '\(pipenv\|poetry\|uv\)$'
    \   ? ' run jedi-language-server'
    \   : ''
    let l:env_string = ''

    if ale#Var(a:buffer, 'python_auto_virtualenv')
        let l:env_string = ale#python#AutoVirtualenvEnvString(a:buffer)
    endif

    return l:env_string . ale#Escape(l:executable) . l:exec_args
endfunction

call ale#linter#Define('python', {
\   'name': 'jedils',
\   'aliases': ['jedi_language_server'],
\   'lsp': 'stdio',
\   'executable': function('ale_linters#python#jedils#GetExecutable'),
\   'command': function('ale_linters#python#jedils#GetCommand'),
\   'project_root': function('ale#python#FindProjectRoot'),
\   'completion_filter': 'ale#completion#python#CompletionItemFilter',
\})
