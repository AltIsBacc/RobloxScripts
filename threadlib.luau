local M = {}

type Thread<T...> = {
    CoroFunc: (T...) -> (),
    Coroutine: thread?,
    Start: (self: Thread<T...>, T...) -> (),
    Stop: (self: Thread<T...>) -> (),
    IsRunning: (self: Thread<T...>) -> boolean
}

function M.NewThread<T...>(func: (T...) -> ()): Thread<T...>
    local Thread = {
        CoroFunc = func,
        Coroutine = nil :: thread?,
    }
    
    function Thread:Start(...: T...)
        Thread.Coroutine = coroutine.create(func)
        coroutine.resume(Thread.Coroutine, ...)
    end
    
    function Thread:Stop()
        if Thread.Coroutine == nil then
            return
        end
        
        local currentCoroutine, _ = coroutine.running()
        if currentCoroutine == Thread.Coroutine then
            coroutine.yield()
        else
            Thread.Coroutine = nil
        end
    end
    
    function Thread:IsRunning(): boolean
        if Thread.Coroutine == nil then
            return false
        end
        return coroutine.status(Thread.Coroutine) == "running" or 
                coroutine.status(Thread.Coroutine) == "suspended"
    end
    
    return Thread
end

return M
