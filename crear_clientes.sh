#!/bin/bash

if [ $# -ne 3 ]; then
  echo "El script necesita 3 argumentos"
  echo "1º Nombre de la nueva máquina y hostname"
  echo "2º Tamaño del volumen que tendrá la nueva máquina"
  echo "3º Nombre de la red a la que tendra que conectarse la máquina"
  exit 1
fi

NOMBRE_MAQUINA=$1
DIMENSION_VOLUMEN=$2
NOMBRE_RED=$3

# Creamos el nuevo volumen a partir de la plantilla plantilla_cliente
virsh --connect qemu:///system vol-create-as default "$NOMBRE_MAQUINA.qcow2" "$DIMENSION_VOLUMEN" --format qcow2 --backing-vol "/var/lib/libvirt/images/plantilla_cliente.qcow2" --backing-vol-format qcow2

# Modificación del nombre del host de la máquina
sudo virt-customize -v -x --connect "qemu:///system" -a "/var/lib/libvirt/images/$NOMBRE_MAQUINA.qcow2" --hostname "$NOMBRE_MAQUINA"


# Redimensionar volumen de la máquina virtual

cp "/var/lib/libvirt/images/$NOMBRE_MAQUINA.qcow2" "/var/lib/libvirt/images/nueva_$NOMBRE_MAQUINA.qcow2"


virt-resize --expand /dev/sda1 "/var/lib/libvirt/images/nueva_$NOMBRE_MAQUINA.qcow2" "/var/lib/libvirt/images/$NOMBRE_MAQUINA.qcow2"

# Creación de la máquina virtual

virt-install --connect qemu:///system --noautoconsole --virt-type kvm --name "$NOMBRE_MAQUINA" --os-variant debian11  --disk path="/var/lib/libvirt/images/$NOMBRE_MAQUINA.qcow2",format=qcow2 --memory 4096 --vcpus 2 --network network=$NOMBRE_RED --import


# Iniciar la máquina, aunque al crearse con el comando anterior ya se inicia

virsh --connect qemu:///system start "$NOMBRE_MAQUINA"

#No lo solita el ejercicio pero lo añado para que se inicie automáticamente
# Activar el inicio automático de la máquina
virsh --connect qemu:///system autostart "$NOMBRE_MAQUINA"