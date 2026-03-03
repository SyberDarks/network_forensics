import pyshark


def extract_information(packet):
    if hasattr(packet, 'ip'):
        # Extract and print relevant information
        print(f"Source: {packet.ip.src}")
        print(f"Destination: {packet.ip.dst}")
        print(f"Protocol: {packet.transport_layer}")
        print(f"Timestamp: {packet.sniff_timestamp}")
        print("\n")
    else:
        print("Packet does not have an IP layer\n")


def analyze_traffic(packet):
    # Check for large data transfers
    if hasattr(packet, "length") and int(packet.length) > 1000:
        print("Potential large data transfer detected!")
        print("\n")


def analyze_pcap(file_path):
    cap = pyshark.FileCapture(file_path)
    for packet in cap:
        extract_information(packet)
        analyze_traffic(packet)


def filter_packets(file_path, filter_criteria):
    cap = pyshark.FileCapture(file_path)
    for packet in cap:
        # Implement your filtering logic here based on the filter_criteria
        if filter_criteria(packet):
            extract_information(packet)
            analyze_traffic(packet)


def filter_tcp(packet):
    return hasattr(packet, 'ip') and packet.transport_layer == "TCP"

# Usage
analyze_pcap(r"C:\Users\Admin\Desktop\Cybersecurity\Wireshark capture\080324.pcap")
filter_packets(r"C:\Users\Admin\Desktop\Cybersecurity\Wireshark capture\080324.pcap", filter_criteria=filter_tcp)
