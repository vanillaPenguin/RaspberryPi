# RaspberryPi Log 1

202110965 이관호  
2023/10/29  
Github Repository : https://github.com/vanillaPenguin/RaspberryPi.git  

### 0.주제

* PC와 RaspberryPi 와의 가장 효율적 연결 방법에 대한 고찰
* RaspberryPi 와 PC의 USB포트를 통한 연결이 고르지 못함

### 1. 개요

* RaspberryPi 는 wifi를 사용할 수 있다
* 그러나 우리가 RaspberryPi 를 위해 사용하는 os는 Buildroot이다.

> ### [What is Buildroot?]
> * Buildroot이란 임베디드 시스템을 위한 소프트웨어를 만드는 데 사용되는 툴이다.
> * 리눅스 커널과, 루트 파일 시스템과 그 안에 들어가는 모든 요소들을 빌드하기 위한
  툴과 설정 파일들을 제공한다  
> * Command
>```Bash
># cat /etc/os-release
>```
> * Result
> ```
> NAME=Buildroot                   
> VERSION=2022.05.1                
> ID=buildroot                     
> VERSION_ID=2022.05.1             
> PRETTY_NAME="Buildroot 2022.05.1"
> ```

> ### [openssh가 없다면]
> **<주의>**
> * 아래 내용은 내가 조사해서 넣은 내용이지만, 잘 동작할지는 확실하지 않다. 
> * 반드시 "망가지고 부서져도 상관없는 사람만" 시도하기를 바란다.
> * RaspberryPi의 기본 세팅을 위해, 우리는 4주차 실습 강의자료 10p 에서
  우리는 RootFileSystem설정 중 다음과 같은 작업을 해 줬었다.
> ```
> dpkg [*]
> dpkg-dev [*]
> ```
> 1. 따라서, .deb파일로 install할 환경이 갖추어져 있다는 뜻이다.   
  -> ssh 설치의 가능성 발견
> 2. Debian 패키지 검색을 통해, openssh-server를 찾을 수 있었다.   
> [arm 아키텍처 버전 존재 (O)]  > https://www.debian.org/distrib/packages
> 3. 우리가 강의자료 4주차 4페이지에서, C 라이브러리를 glibc로 설정했다  
>  (그리고 2페이지에서, 이를 위해 libc6-dev를 설치했다).
> 4. 또, 우리가 사용하는 보드는 arm64아키텍처이다. 
> 5. 따라서, openssh-server 패키지에서 lib6 C라이브러리를 위한 arm64 아키텍처 버전을 설치한다.  
> ***Download links***  
> * 아키텍처 선택 :          https://packages.debian.org/bookworm/libc6-udeb  
> * arm64 아키텍처 : https://packages.debian.org/bookworm/arm64/libc6-udeb/download


### 2. 연구

* 사실 Buildroot를 강의자료대로 만들었다면, openssh-server가 설치되어 있다.
* (Client는 설치되어 있는지 모르겠지만, 당장은 필요없을 것 같다.)
* Command
```Bash
# which sshd
```
* Result
```
/usr/bin/sshd
```

### tftp : "Trivial File Transfer Protocol"
- Command
```Bash
$ sudo apt install tftp tftpd xinetd -y
$ sudo vim /etc/xinetd.d/tftp
$ sudo mkdir /tftpboot
$ sudo /etc/initd/xinetd restart
```

> Vim edit /etc/xinetd.d/tftp  
> socket type = dgram          : 데이터그램 (UDP) 소켓을 사용한다  
> protocol = udp               : TFTP는 UDP 프로토콜을 사용한다 -> 이걸로 연결하겠다는 소리  
> wait = yes                   : xinetd 가 요청을 기다리는 동안 다른 요청을 받지 않는다.  
> user = root                  : TFTP를 사용할 때, 사용자는 root권한이다.  
> server = /usr/sbin/in.tftpd  : TFTP데몬의 위치를 지정한다.  
> server_args = -s /tftpboot   : TFTP데몬에 전달되는 인수이다. -s는 TFTP의 루트 디렉토리를 지정하며, 여기서는 /tftpboot이다.  
> disable = no                 : TFTP서비스를 활성화한다.  
> per_source = 11              : IP주소의 동시 연결 수를 제한한다.  
> cps = 100 2                  : 초당 연결 횟수를 제한한다.  
> flag = IPv4                  : IPv4를 활용한다  

### 2. 가설

* 위의 설정으로 PC의 IP주소를 통하여, RaspberryPi side에서 파일을 가져올 수 있을 것이다.
- Command
```Bash
# tftp [PC_IP_address] -c get [file]
```
* PC의 해당 네트워크 인터페이스에 대한 IP주소 확인 방법
- Command
```Bash
$ ip a
```
- Result (assumption)
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000           
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00                                             
    inet 127.0.0.1/8 scope host lo                                                                    
       valid_lft forever preferred_lft forever                                                        
                                                                                                   
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000 
    link/ether 12:34:56:78:9a:bc brd ff:ff:ff:ff:ff:ff                                                
    inet 192.168.1.10/24 brd 192.168.1.255 scope global eth0                                          
       valid_lft forever preferred_lft forever  
```
* 이때 2: eth0 아래 inet 192.168.1.10 이 이 네트워크 인터페이스에 대한 이 PC의 IP주소이다.
* 따라서 이 IP에 대해서 위의 tftp 커맨드를 실행하면 실행 가능할것이다(가정). 예상 코드는 아래와 같다.
- Command
```Bash
# tftp 192.168.1.10 -c get button_mmap.c 
```

### 4. 이후 목표 설정

* Raspberry Pi 에서 git을 사용할 수 있을 것이다.
* 순서대로 전체 디스크 용량과 사용 가능한 용량을 확인하는 코드이다.
```Bash
# df -h
# free -h
```
* 다음은 각각 apt패키지 매니저에서 git 패키지의 크기와, git을 모의로 설치하는 코드이다.
```Bash
$ apt show git
$ sudo apt install --dry-run git
```