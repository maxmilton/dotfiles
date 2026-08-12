for dep in (paru -Qtdq)
    set users (
        begin
            paru -Ssaq --searchby=makedepends $dep
            paru -Ssaq --searchby=checkdepends $dep
        end | sort -u | comm -12 (paru -Qmq | sort | psub) -
    )

    if test (count $users) -gt 0
        printf '%s <- %s\n' $dep (string join ', ' $users)
    end
end
