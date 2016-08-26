function Restart-Explorer {
    try{sleep 2 ; Stop-Process -processname explorer -Force -ErrorAction Stop | Out-Null} catch {}
}