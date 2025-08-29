#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# pip install mcrcon
from mcrcon import MCrcon

HOST = "127.0.0.1"
PORT = 25575
PASSWORD = "123123123"

def main():
    try:
        # timeout можно подправить при необходимости
        with Mcrcon(HOST, PASSWORD, port=PORT, timeout=5) as rcon:
            print(f"[OK] Подключено к RCON {HOST}:{PORT}. Введите команды.")
            print("Подсказка: 'exit' или 'quit' — выход.")
            while True:
                try:
                    cmd = input("rcon> ").strip()
                except (EOFError, KeyboardInterrupt):
                    print("\n[!] Выход.")
                    break

                if not cmd:
                    continue
                if cmd.lower() in ("exit", "quit"):
                    print("[*] Отключение...")
                    break

                try:
                    resp = rcon.command(cmd)
                    # У некоторых команд ответа нет — это нормально.
                    if resp is None or resp == "":
                        print("(пустой ответ)")
                    else:
                        print(resp)
                except Exception as e:
                    print(f"[Ошибка при выполнении команды] {e}")

    except Exception as e:
        print(f"[Не удалось подключиться к RCON] {e}")
        print("Проверьте, что сервер запущен и RCON включён.")

if __name__ == "__main__":
    main()
