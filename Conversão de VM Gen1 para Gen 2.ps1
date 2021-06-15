# Script para converte máquina virtual geração 1 para geração 2 do Hyper-V - Créditos Gabriel Luiz - www.gabrielluiz.com ##


# Observação: Execute os comandos no Powershell.exe, não utilize o PowerShell_ISE.exe.


# Se o disco ainda estiver no formato .VHD, ele deve primeiro ser convertido para o formato .VHDX. Utilie os comandos abaixo para fazer isto.


# Execute o Powershell como administrador e execute o seguinte comando:


Convert-VHD -Path "D:\Hyper-V\Windows Server 2012 Ge 1.vhd" -DestinationPath "D:\Hyper-V\Windows Server 2012 Ge 1.vhdx"


# Agora, o disco virtual no formato .vhdx deve ser anexado (montagem) no sistema operacional host:


Mount-VHD -Path 'V:\Hyper-V\Virtual Hard Disks\Windows Server 2012 Ge 1.vhdx' # Monta um ou mais discos rígidos virtuais.



# Os próximos passos exigem o número de disco do disco virtual. Execute o comando abaixo:


get-disk # Obtém um ou mais discos visíveis para o sistema operacional.


#Observação: Memorize o número do disco.


# Depois disso, a configuração de partição de disco deve ser convertida de MBR para GPT com a ferramenta gratuita Gptgen.



<#

Observações:

Faça o download do Gptgen neste link: https://sourceforge.net/projects/gptgen/files/latest/download

Informe o caminho do executavel gptgen.exe.

Neste exemplo o número do disco e 11.

#>


C:\gptgen-1.1\gptgen.exe -w \\.\physicaldrive11 


# Agora, o disco virtual deve ser desmontado e, em seguida montar novamente.

Dismount-VHD -Path 'V:\Hyper-V\Virtual Hard Disks\Windows Server 2012 Ge 1.vhdx' # Desmonta um disco rígido virtual.

Mount-VHD -Path 'V:\Hyper-V\Virtual Hard Disks\Windows Server 2012 Ge 1.vhdx' # Monta um ou mais discos rígidos virtuais.



# Acesse o Diskpart. O interpretador de comandos do DiskPart ajuda você a gerenciar as unidades de seu computador (discos, partições, volumes ou discos rígidos virtuais).

diskpart


# Em seguida, listar de todos os discos deve ser consultada e o disco virtual montado deve ser selecionado.


# Exibe todos os discos no computador.

list disk


# Desloca o foco para um disco, partição, volume ou VHD (disco rígido virtual).

select disk 11


# Em seguida, a listar todas as partições deve ser consultada e a partição "Sistema Reservado" deve ser selecionada.

list partition


# Em seguida, a partição "Sistema Reservado" deve ser selecionada.

# Desloca o foco para um disco, partição, volume ou VHD (disco rígido virtual).

select partition 1


# Em seguida a partição selecionada deve ser excluída:

# Exclui uma partição ou um volume.

delete partition


# Agora, uma partição EFI deve ser criada, formatada e atribuída a uma letra de unidade:

# Cria uma partição em um disco, um volume em um ou mais discos ou um VHD (disco rígido virtual).

create partition efi size=100
format quick fs=fat32 label="System"
assign letter="S"



# O próximo passo é criar uma partição MSR:

# Você também pode fazer sem o parâmetro do tamanho da partição, que então preenche os 200 MB restantes. 

# Cria uma partição em um disco, um volume em um ou mais discos ou um VHD (disco rígido virtual).

create partition msr size=128

# Agora é só sair do Diskpart.

exit

# A ferramenta bcdboot é então usada para copiar os arquivos de inicialização UEFI importantes para a partição do sistema. onde h: é a letra de disco da partição virtual do Windows e s: é a letra de disco da partição virtual EFI:

# BCDBoot é uma ferramenta de linha de comando usada para configurar os arquivos de inicialização em um PC ou dispositivo para executar o sistema operacional Windows. 


bcdboot h:\windows /s s: /f UEFI


# Agora, o disco virtual deve ser desmontado novamente:

Dismount-VHD -Path 'V:\Hyper-V\Virtual Hard Disks\Windows Server 2012 Ge 1.vhdx' # Desmonta um disco rígido virtual.

# Agora é só fechar do Powertshell.

exit


# Finalmente, uma nova Máquina Virtual geração 2 (Gen2-VM) agora pode ser criada com a configuração de rede documentada e o disco virtual editado pode ser adicionado ao controlador SCSI.

#  Assista o vídeo para aprender como foi o processo de conversão de máquina virtual geração 1 para geração 2 do Hyper-V.

<#

Referências:


https://docs.microsoft.com/en-us/powershell/module/storage/get-disk?view=windowsserver2019-ps&WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/en-us/powershell/module/hyper-v/mount-vhd?view=windowsserver2019-ps&WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/en-us/powershell/module/hyper-v/dismount-vhd?view=windowsserver2019-ps&WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/pt-br/windows-server/administration/windows-commands/diskpart?WT.mc_id=WDIT-MVP-5003815

https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/bcdboot-command-line-options-techref-di?WT.mc_id=WDIT-MVP-5003815


#>