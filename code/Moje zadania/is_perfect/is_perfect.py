import dis

def czy_doskonala(liczba):
    sum=0
    for i in range(1, liczba):
        if liczba%i==0:
            sum+=i

    return sum==liczba


def interval(zakres):
    for i in range(1, zakres):
        if czy_doskonala(i):
            print(i, " ")

dis.dis(czy_doskonala)
dis.dis(interval)